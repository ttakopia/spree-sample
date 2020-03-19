# encoding: UTF-8

# Copyright 2012 Twitter, Inc
# http://www.apache.org/licenses/LICENSE-2.0

module TwitterCldr
  module Segmentation
    class Metadata
      attr_reader :values

      def initialize(values)
        @values = values
      end

      def category_count
        @category_count ||= values[:category_count]
      end
    end
  end
end
