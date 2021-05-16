# frozen_string_literal: true

module CustomException
  class CompulsoryParamMissing < StandardError
    def message
      'Name & Email are compulsory.'
    end
  end

  class DataParamMissing < StandardError
    def message
      'File/Text/Url is needed.'
    end
  end

  class OnlyOneDataParamAllowed < StandardError
    def message
      'Only one is allowed from File/Text/Url.'
    end
  end

  class NotPersonalityUrl < StandardError
    def message
      'Provided URL is not of PersonalityTest website.'
    end
  end

  module PersonalityTest
    class InvalidData < StandardError
      def message
        'The provided data/file is invalid and not parsable.'
      end
    end

    class InvalidUrl < StandardError
      def message
        'Invalid URL provided.'
      end
    end
  end
end
