require 'guard'
require 'guard/guard'

module Guard
  class Svg2png < Guard
    DEFAULTS = {
        run_all_on_start: false
    }
    # Initializes a Guard plugin.
    # Don't do any work here, especially as Guard plugins get initialized even if they are not in an active group!
    #
    # @param [Array<Guard::Watcher>] watchers the Guard plugin file watchers
    # @param [Hash] options the custom Guard plugin options
    # @option options [Symbol] group the group this Guard plugin belongs to
    # @option options [Boolean] any_return allow any object to be returned from a watcher
    #
    def initialize(watchers = [], options = {})
      super

      @options = DEFAULTS.merge(options)
    end

    # Called once when Guard starts. Please override initialize method to init stuff.
    #
    # @raise [:task_has_failed] when start has failed
    # @return [Object] the task result
    #
    def start
        UI.info "Guard::Svg2png is running"
    end

    # Called when `stop|quit|exit|s|q|e + enter` is pressed (when Guard quits).
    #
    # @raise [:task_has_failed] when stop has failed
    # @return [Object] the task result
    #
    def stop
    end

    # Called when `reload|r|z + enter` is pressed.
    # This method should be mainly used for "reload" (really!) actions like reloading passenger/spork/bundler/...
    #
    # @raise [:task_has_failed] when reload has failed
    # @return [Object] the task result
    #
    def reload
    end

    # Called when just `enter` is pressed
    # This method should be principally used for long action like running all specs/tests/...
    #
    # @raise [:task_has_failed] when run_all has failed
    # @return [Object] the task result
    #
    def run_all
        # UI.info 'run all'
    end

    # Default behaviour on file(s) changes that the Guard plugin watches.
    # @param [Array<String>] paths the changes files or paths
    # @raise [:task_has_failed] when run_on_change has failed
    # @return [Object] the task result
    #
    def run_on_changes(paths)
        # UI.info 'changes'
        svg2png(paths)
    end

    # Called on file(s) additions that the Guard plugin watches.
    #
    # @param [Array<String>] paths the changes files or paths
    # @raise [:task_has_failed] when run_on_additions has failed
    # @return [Object] the task result
    #
    def run_on_additions(paths)
        # UI.info 'additions'
        svg2png(paths)
    end

    # Called on file(s) modifications that the Guard plugin watches.
    #
    # @param [Array<String>] paths the changes files or paths
    # @raise [:task_has_failed] when run_on_modifications has failed
    # @return [Object] the task result
    #
    def run_on_modifications(paths)
        # UI.info 'modifications'
        svg2png(paths)
    end

    # Called on file(s) removals that the Guard plugin watches.
    #
    # @param [Array<String>] paths the changes files or paths
    # @raise [:task_has_failed] when run_on_removals has failed
    # @return [Object] the task result
    #
    def run_on_removals(paths)
        # UI.info 'removals'
        paths.each do |path|
            UI.info "Removing PNG for deleted SVG file: #{path}"
            dest = get_destination(path)
            File.delete(dest) if File.exists?(dest)
        end
    end

    def svg2png(paths)
        UI.info "Running svg2png:"

        if paths.any?
            paths.each do |path|
                raise IOError, 'File not found: #{path}' if !File.exists?(path)

                if !ignored?(path) then
                    source = path
                    dest = get_destination(path)
                    UI.info "Rendering #{source} to #{dest}"
                    command = build_command(source,dest)
                    UI.debug command
                    system command
                else
                    UI.debug "File ignored: #{path}"
                end
            end
        else
            UI.debug 'No paths.'
        end
    end

    def build_command(source, dest)

        command = "convert -background none \"#{source}\" \"#{dest}\""
    end

    def get_destination(path)
        dest = File.dirname(path) + '/' + File.basename(path, File.extname(path)) + '.png'
    end

    def get_ignores(path)
        dir = File.join File.expand_path('.'), File.dirname(path)
        ignore_file = nil
        while File.expand_path(dir) != '/' do
            if File.exists?(File.join dir, '.s2p_ignore') then
                ignore_file = File.join dir, '.s2p_ignore'
                break
            end
            dir = File.join dir, '..'
        end

        if ignore_file == nil then
            return []
        end

        file = File.open(ignore_file, "rb")
        contents = Array.new

        file.each_line { |line|
            contents.push line
        }
        file.close

        contents
    end

    def ignored?(path)
        ignores = get_ignores(path)
        ignores.each do |fspec|
            if File.fnmatch(fspec, path) then
                UI.debug "Change ignored: #{path} matches #{fspec}"
                return true
            end
        end
        return false
    end
  end
end
