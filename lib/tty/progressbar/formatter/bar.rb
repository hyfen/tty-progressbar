# frozen_string_literal: true

module TTY
  class ProgressBar
    # Used by {Pipeline} to format bar
    #
    # @api private
    class BarFormatter
      MATCHER = /:bar/.freeze

      def initialize(progress)
        @progress = progress
      end

      # Determines whether this formatter is applied or not.
      #
      # @param [Object] value
      #
      # @return [Boolean]
      #
      # @api private
      def matches?(value)
        !!(value.to_s =~ MATCHER)
      end

      # Format :bar token
      #
      # @param [String] value
      #  the value being formatted
      #
      # @api public
      def format(value)
        without_bar = value.gsub(/:bar/, "")
        available_space = [0, ProgressBar.max_columns -
                              ProgressBar.display_columns(without_bar) -
                              @progress.inset].max
        width = [@progress.width, available_space].min
        complete_bar_length    = (width * @progress.ratio).round
        complete_char_length   = ProgressBar.display_columns(@progress.complete)
        incomplete_char_length = ProgressBar.display_columns(@progress.incomplete)
        head_char_length       = ProgressBar.display_columns(@progress.head)

        # division by char length only when unicode chars are used
        # otherwise it has no effect on regular ascii chars
        complete_items = [
          complete_bar_length / complete_char_length,
          # or see how many incomplete (unicode) items fit
          (complete_bar_length / incomplete_char_length) * incomplete_char_length
        ].min

        complete_width = complete_items * complete_char_length
        incomplete_width = width - complete_width
        incomplete_items = [
          incomplete_width / incomplete_char_length,
          # or see how many complete (unicode) items fit
          (incomplete_width / complete_char_length) * complete_char_length
        ].min

        complete   = Array.new(complete_items, @progress.complete)
        incomplete = Array.new(incomplete_items, @progress.incomplete)

        if complete.size > 0 && head_char_length > 0
          extra_space = width - complete_width -
                        incomplete_items * incomplete_char_length
          if 0 < extra_space && (head_char_length == extra_space &&
                                 complete_char_length == extra_space)
            complete << @progress.head
          else
            complete[-1] = @progress.head
          end
        end

        value.gsub(MATCHER, "#{complete.join}#{incomplete.join}")
      end
    end # BarFormatter
  end #  ProgressBar
end # TTY
