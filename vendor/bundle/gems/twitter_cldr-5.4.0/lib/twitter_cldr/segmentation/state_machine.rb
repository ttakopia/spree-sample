# encoding: UTF-8

# Copyright 2012 Twitter, Inc
# http://www.apache.org/licenses/LICENSE-2.0

require 'base64'
require 'singleton'

module TwitterCldr
  module Segmentation
    class StateMachine
      include Singleton

      START_STATE = 1
      STOP_STATE = 0
      NEXT_STATES = 4
      ACCEPTING = 0

      class << self
        def instance(boundary_type, locale)
          resource_path = find_resource(boundary_type, locale)

          cache[resource_path] ||= begin
            rsrc = TwitterCldr.get_resource(resource_path)

            new(
              boundary_type,
              locale,
              Metadata.new(rsrc[:metadata]),
              StateTable.load16(rsrc[:forward_table]),
              StateTable.load16(rsrc[:backward_table]),
              StatusTable.load(rsrc[:status_table]),
              CategoryTable.load16(rsrc[:category_table])
            )
          end
        end

        private

        def find_resource(boundary_type, locale)
          path = TwitterCldr.resource_file_path(
            ['shared', 'segments', 'rules', locale, boundary_type]
          )

          return path if TwitterCldr.resource_exists?(path)

          TwitterCldr.resource_file_path(
            ['shared', 'segments', 'rules', 'root', boundary_type]
          )
        end

        def cache
          @cache ||= {}
        end
      end

      attr_reader :boundary_type, :locale
      attr_reader :metadata, :ftable, :rtable, :status_table, :category_table

      def initialize(boundary_type, locale, metadata, ftable, rtable, status_table, category_table)
        @boundary_type = boundary_type
        @locale = locale
        @metadata = metadata
        @ftable = ftable
        @rtable = rtable
        @status_table = status_table
        @category_table = category_table
      end

      def handle_next(cursor)
        result = initial_position = cursor.position
        state = START_STATE
        row = state * (metadata.category_count + 4)
        category = 3
        mode = :run

        if ftable.bof_required?
          category = 2
          mode = :start
        end

        until state == STOP_STATE
          if cursor.eos?
            break if mode == :stop
            mode = :stop
            category = 1
          elsif mode == :run
            category = category_table.get(cursor.codepoint)

            if (category & 0x4000) != 0
              category &= ~0x4000
            end

            cursor.advance
          else
            mode = :run
          end

          state = ftable[row + NEXT_STATES + category]
          row = state * (metadata.category_count + 4)

          if ftable[row + ACCEPTING] == -1
            # match found
            result = cursor.position
          end
        end

        cursor.position = result

        # don't let cursor get stuck
        if cursor.position == initial_position
          cursor.advance
        end

        result
      end
    end
  end
end
