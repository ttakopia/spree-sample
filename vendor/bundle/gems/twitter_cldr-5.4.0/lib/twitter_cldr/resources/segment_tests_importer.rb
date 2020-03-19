# encoding: UTF-8

# Copyright 2012 Twitter, Inc
# http://www.apache.org/licenses/LICENSE-2.0

require 'fileutils'

module TwitterCldr
  module Resources
    class SegmentTestsImporter < Importer

      CONFORMANCE_FILES = [
        'ucd/auxiliary/WordBreakTest.txt',
        'ucd/auxiliary/SentenceBreakTest.txt',
        'ucd/auxiliary/GraphemeBreakTest.txt',
        'ucd/auxiliary/LineBreakTest.txt'
      ]

      DICTIONARY_BREAK_SAMPLES = {
        # Chinese
        zh: '無畏號航空母艦是一艘隸屬於美國海軍的航空母艦，為艾塞克斯級航空母艦的三號艦。'\
            '無畏號於1941年開始建造，1943年下水服役，開始參與太平洋戰爭。戰後無畏號退役封存，'\
            '在韓戰後開始進行SCB-27C改建，又在期間重編為攻擊航母，於1954年在大西洋艦隊重新服役。'\
            '稍後無畏號又進行SCB-125現代化改建，增設斜角飛行甲板。1962年無畏號重編為反潛航母，'\
            '舷號改為CVS-11，繼續留在大西洋及地中海執勤。稍後無畏號參與美國的太空計畫，'\
            '分別擔任水星-宇宙神7號及雙子座3號的救援船。1966年至1969年，無畏號曾三次前往西太平洋，'\
            '參與越戰。無畏號在1974年退役，並一度預備出售拆解；但在民間組織努力下，'\
            '海軍在1981年將無畏號捐贈到紐約作博物館艦。1986年，無畏號獲評為美國國家歷史地標。',

        ko: '파일은 이용자가 공용 또는 위키백과 한국어판에 업로드하여 라이선스에 따라 사용 가능한 형태로 제공됩니다. '\
            '업로드된 파일은 간단한 조작으로 페이지에 삽입할 수 있습니다. 업로드는 신규 이용자를 제외한 등록 이용자라면 '\
            '가능합니다. 파일을 업로드하기 전에 다음 문단의 업로드를 할 수 없는 파일을 반드시 읽어 보시기 바랍니다. '\
            '공용 이용 방법 및 업로드에 대해서는 Commons:초보자 길라잡이/업로드를 읽어 보시기 바랍니다. 업로드하는 '\
            '페이지는 위키백과:파일 올리기를 참조하십시오. 파일의 라이선스가 삽입되는 위키백과의 문서와는 별도로 '\
            '개별적으로 설정해야 합니다. 파일을 업로드할 때 적절한 라이선스를 선택하고 반드시 표시하십시오.',

        # Thai
        th: 'ธงไชย แมคอินไตย์ ชื่อเล่น เบิร์ด (เกิด 8 ธันวาคม พ.ศ. 2501) เป็นนักร้อง นักแสดงชาวไทย '\
            'ได้รับขนานนามว่าเป็น "ซูเปอร์สตาร์เมืองไทย" โดยคนไทยรู้จักกันดี เรียกกันว่า : พี่เบิร์ด '\
            'แรกเข้าวงการบันเทิงเป็นนักแสดงสมทบ ต่อมาได้รับบทพระเอก โดยภาพยนตร์ที่สร้างชื่อเสียงให้กับเขาที่สุดเรื่อง '\
            'ด้วยรักคือรัก ส่วนละครที่สร้างชื่อเสียงที่สุดของเขาคือบท "โกโบริ" ในละครคู่กรรม '\
            'ด้านวงการเพลงซึ่งเป็นอาชีพหลักเขาเริ่มต้นจากการประกวดร้องเพลงของสยามกลการ '\
            'ต่อมาเป็นนักร้องในสังกัดบริษัท จีเอ็มเอ็ม แกรมมี่ จำกัด (มหาชน) ซึ่งประสบความสำเร็จสูงสุดของประเทศไทย'\
            'มียอดจำหน่ายอยู่ในระดับแนวหน้าของทวีปเอเชียยอดรวมกว่า 25 ล้านชุด',

        # Khmer
        km: 'វីគីភីឌា (អង់គ្លេស ៖ Wikipedia) ជាសព្វវចនាធិប្បាយសេរីច្រើនភាសានៅលើអ៊ីនធឺណិត '\
            'ដែលមនុស្សគ្រប់គ្នាអាចអាននិងធ្វើឱ្យមាតិកាទាន់សម័យបន្ថែមទៀត '\
            'ធ្វើឱ្យវីគីភីឌាសព្វវចនាធិប្បាយបានក្លាយទៅជាការកែប្រែ '\
            'ការប្រមូលនិងការអភិរក្សរាប់រយរាប់ពាន់នាក់នៃអ្នកស្ម័គ្រចិត្តនៅជុំវិញពិភពលោក '\
            'តាមរយៈកម្មវិធីដែលគេហៅថាមេឌាវិគី ។ វីគីភីឌាចាប់ផ្តើមនៅថ្ងៃទី ១៥ មករា ឆ្នាំ ២០០១ '\
            'ដោយចាប់ផ្តើមគម្រោងពីឈ្មោះសព្វវចនាធិប្បាយណូ៉ភីឌាដែលសរសេរដោយហ្ស៊ីម្ម៊ី '\
            'វេល្ស និងឡែរ្រី សែងក័រ ។ នៅបច្ចុប្បន្ននេះ វីគីភីឌាមានទាំង់អស់ ២៩៣ ភាសា[៤] ដោយវីគីភីឌាភាសាខ្មែរមាន '\
            '៧៨៩៨ អត្ថបទ ។ មានវីគីភីឌាច្រើនជាង ៥០ ភាសាដែលមានអត្ថបទច្រើនជាង ១០០.០០០ អត្ថបទ ។ '\
            'វីគីភីឌាភាសាអាល្លឺម៉ងត្រូវបានគេចែកចាយនៅក្នុងទ្រង់ទ្រាយឌីវីឌី-រ៉ូម ។',

        # Lao
        lo: 'ວິກິພີເດຍ (ອັງກິດ: Wikipedia) ເປັນສາລະນຸກົມເນື້ອຫາເສລີຫຼາຍພາສາໃນເວັບໄຊ້ '\
            'ເຊິ່ງໄດ້ຮັບການສະໜັບສະໜຸນຈາກມູນລະນິທິວິກິພີເດຍ ອົງກອນບໍ່ສະແຫວງຫາຜົນກຳໄລ ເນື້ອຫາກວ່າ 35 ລ້ານບົດຄວາມ '\
            '(ສະເພາະວິກິພີເດຍພາສາອັງກິດມີເນື້ອຫາກວ່າ 4.9 ລ້ານບົດຄວາມ) ເກີດຂຶ້ນຈາກການຮ່ວມຂຽນຂອງອາສາສະໝັກທົ່ວໂລກ '\
            'ທຸກຄົນທີ່ສາມາດເຂົ້າເຖິງວິກິພີເດຍສາມາດຮ່ວມແກ້ໄຂເກືອບທຸກບົດຄວາມໄດ້ຢ່າງເສລີ ໂດຍມີຜູ້ຂຽນປະມານ 100,000ຄົນ '\
            'ຈົນເຖິງເດືອນເມສາ ຄ.ສ. 2013 ວິກິພີເດຍມີ 286 ຮຸ່ນພາສາ ແລະ '\
            'ໄດ້ກາຍມາເປັນງານອ້າງອິງທົ່ວໄປທີ່ໃກຍ່ທີ່ສຸດແລະໄດ້ຮັບຄວາມນິຍົມຫຼາຍທີ່ສຸດຢູ່ອິນເຕີເນັດ ຈົນຖືກຈັດເປັນເວັບໄຊ້ ອັນດັບທີ 6 '\
            'ທີ່ມີຜູ້ເຂົ້າເບິ່ງຫຼາຍທີ່ສຸດໃນໂລກ ຕາມການຈັດອັນດັບຂອງອາເລັກຊ້າ ດ້ວຍຈຳນວນຜູ້ອ່ານກວ່າ 365 ລ້ານຄົນ '\
            'ມີການປະເມີນວ່າວິກິພີເດຍມີການຄົ້ນຫາຂໍ້ມູນໃນວິກິພີເດຍກວ່າ 2,700 ລ້ານເທື່ອຕໍ່ເດືອນໃນສະຫະລັດ ອາເມຣິກາ',

        # Burmese
        my: 'ကိန်းဆိုသည်မှာ ရေတွက်ရန်နှင့် တိုင်းတာရန် အတွက် အသုံးပြုသော သင်္ချာဆိုင်ရာ အရာဝတ္ထုတစ်ခု '\
            'ဖြစ်သည်။ သင်္ချာပညာတွင် ကိန်းဂဏန်းများ၏ အဓိပ္ပာယ်ဖွင့်ဆိုချက်ကို တဖြည်းဖြည်း ချဲ့ကားလာခဲ့သဖြင့် '\
            'နှစ်ပေါင်းများစွာ ကြာသောအခါတွင် သုည၊ အနှုတ်ကိန်းများ (negative numbers)၊ ရာရှင်နယ်ကိန်း '\
            '(rational number) ခေါ် အပိုင်းကိန်းများ၊ အီရာရှင်နယ်ကိန်း (irrational number) ခေါ် '\
            'အပိုင်းကိန်းမဟုတ်သောကိန်းများ နှင့် ကွန်ပလက်စ်ကိန်း (complex number) ခေါ် ကိန်းရှုပ်များ စသည်ဖြင့် '\
            'ပါဝင်လာကြသည်။ သင်္ချာဆိုင်ရာ တွက်ချက်မှုများ (mathematical operations) တွင် ဂဏန်းတစ်ခု '\
            'သို့မဟုတ် တစ်ခုထက်ပိုသော ဂဏန်းများကို အဝင်ကိန်းအဖြစ် လက်ခံကြပြီး ဂဏန်းတစ်ခုကို အထွက်ကိန်း '\
            'အဖြစ် ပြန်ထုတ်ပေးသည်။ ယူနရီ တွက်ချက်မှု (unary operation) ခေါ် တစ်လုံးသွင်းတွက်ချက်မှုတွင် '\
            'ဂဏန်းတစ်ခုကို အဝင်ကိန်း အဖြစ် လက်ခံပြီး ဂဏန်းတစ်ခုကို အထွက်ကိန်း အဖြစ် ထုတ်ပေးသည်။ '
      }.freeze

      requirement :unicode, Versions.unicode_version, CONFORMANCE_FILES
      requirement :icu, Versions.icu_version
      output_path 'shared/segments/tests'
      ruby_engine :jruby

      def execute
        import_conformance_files
        import_dictionary_break_tests
        import_combined_dictionary_break_test
      end

      private

      def import_conformance_files
        CONFORMANCE_FILES.each do |test_file|
          import_conformance_file(test_file)
        end
      end

      def import_conformance_file(conformance_file)
        source_file = conformance_source_path_for(conformance_file)
        FileUtils.mkdir_p(File.dirname(source_file))
        result = UnicodeFileParser.parse_standard_file(source_file).map(&:first)
        output_file = conformance_output_path_for(conformance_file)
        FileUtils.mkdir_p(File.dirname(output_file))
        File.write(output_file, YAML.dump(result))
      end

      def import_dictionary_break_tests
        DICTIONARY_BREAK_SAMPLES.each do |locale, text_sample|
          data = create_dictionary_break_test(locale.to_s, text_sample)
          dump_dictionary_break_test(locale, data)
        end
      end

      def import_combined_dictionary_break_test
        text_sample = DICTIONARY_BREAK_SAMPLES.values.join(' ')
        data = create_dictionary_break_test('en', text_sample)
        dump_dictionary_break_test('combined', data)
      end

      def create_dictionary_break_test(locale, text_sample)
        done = break_iterator.const_get(:DONE)
        iter = break_iterator.get_word_instance(ulocale_class.new(locale))
        iter.set_text(text_sample)
        start = iter.first
        segments = []

        until (stop = iter.next) == done
          segments << text_sample[start...stop]
          start = stop
        end

        {
          locale: locale,
          text: text_sample,
          segments: segments
        }
      end

      def dump_dictionary_break_test(name, data)
        output_file = dictionary_test_output_path_for(name)
        FileUtils.mkdir_p(File.dirname(output_file))
        File.write(output_file, YAML.dump(data))
      end

      def conformance_source_path_for(conformance_file)
        requirements[:unicode].source_path_for(conformance_file)
      end

      def conformance_output_path_for(conformance_file)
        file = underscore(File.basename(conformance_file).chomp(File.extname(conformance_file)))
        File.join(params.fetch(:output_path), "#{file}.yml")
      end

      def dictionary_test_output_path_for(locale)
        File.join(params.fetch(:output_path), 'dictionary_tests', "#{locale}.yml")
      end

      def underscore(str)
        str.gsub(/(.)([A-Z])/, '\1_\2').downcase
      end

      def ulocale_class
        @ulocale_class ||= requirements[:icu].get_class('com.ibm.icu.util.ULocale')
      end

      def break_iterator
        @break_iterator ||= requirements[:icu].get_class('com.ibm.icu.text.BreakIterator')
      end

    end
  end
end
