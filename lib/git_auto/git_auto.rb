# frozen_string_literal: true

# Class to encapsulate git operations on directories specified in the
# initializer.
class GitAuto
  attr_accessor :run_stat
  attr_reader :dirs

  def initialize(dirs)
    @dirs = dirs.select { |d| File.directory?(d) }
              .map { |d| File.expand_path(d) }
    @run_stat = nil
  end

  def getenv
    env_files = [File.expand_path("~/.keychain/#{ENV['HOSTNAME']}-sh"),
                 File.expand_path("~/.keychain/#{ENV['HOSTNAME']}-sh-gpg")]
    result = ENV.clone
    env_files.each do |fname|
      if File.readable?(fname)
        File.open(fname) do |f|
          f.each_line do |line|
            next unless line =~ /^\s*(SSH|GPG)/

            cmd = line.split(';').grep(/=/).first
            kv = cmd.split('=')
            if kv.size == 2
              result[kv[0].to_s] = kv[1].to_s
            end
          end
        end
      end
    end
    result
  end

  # Run the given command, log its output to the logger, and return whether
  # the command succeeded. Set the class instance variable @run_stat to the
  # resulting status from running the command for access by the caller.
  def run_and_log(cmd, logger = nil)
    env = getenv
    logger ||= Logger.new(STDERR)
    logger.info "Running: '#{cmd}'"
    stdout_str, stderr_str, status = Open3.capture3(env, cmd)
    self.run_stat = status
    if status.success?
      logger.info "Stdout: #{stdout_str}" unless stdout_str.blank?
    else
      logger.error "Stdout: #{stdout_str}" unless stdout_str.blank?
      logger.error "!Error: #{stderr_str}" unless stderr_str.blank?
    end
    status.success?
  end

  # Create a git repository in current directory unless one already exists.
  def ensure_git_dir(logger = nil)
    unless run_and_log('git rev-parse --git-dir >/dev/null', logger)
      # initialize git repo here
      return run_and_log('git init')
    end

    true
  end

  # Return true if there have been any changes in the current directory since
  # the last git commit.
  def git_changes?(logger = nil)
    # Note: git-diff returns 0 if no changes, 1 if changes, and 2 if there was
    # an error.  Thus, run_and_log will falsely report that there was an error
    # if there are changes, so beware.
    run_and_log('git diff --exit-code', logger)
    if run_stat.exitstatus == 1
      true
    elsif run_stat.exitstatus.zero?
      false
    else
      raise "git diff failed: #{run_stat.inspect}"
    end
    true
  end

  # Return whether the current directory has a remote named origin with branch
  # master.
  def git_has_remote?(logger)
    run_and_log('git ls-remote --exit-code . origin/master', logger)
  end

  # Construct a centered banner that is width chars wide after taking into
  # account the size of title.
  def banner(title, width: 80)
    padsize = [2, (width - title.size) / 2 - 2].max
    head_left = "\n" + '=' * padsize + ' '
    head_right = ' ' + '=' * padsize
    head_left + title + head_right
  end

  def run
    # Set up the logger
    log_name = '~/log/git-auto.log'
    log_name = File.expand_path(log_name)
    log_dir = File.dirname(log_name)
    FileUtils.mkdir_p(log_dir)

    logger = Logger.new(log_name, 'monthly')
    logger ||= Logger.new(STDERR)

    dirs.each do |dir|
      now = DateTime.now
      logger.info banner("#{dir} at #{now}")
      Dir.chdir(dir) do |d|
        logger.info "Make sure '#{d}' is a git repository"
        next unless ensure_git_dir(logger)

        logger.info "Determine if there are uncommitted changes to '#{d}'"
        unless git_changes?(logger)
          logger.info "  Directory '#{d} has no changes to commit"
          next
        end
        logger.info "Stage changed files in '#{d}'"
        next unless run_and_log('git add .', logger)

        logger.info "Commit the changes to '#{d}'"
        next unless run_and_log("git commit -am  'autocommit #{now}'  ", logger)

        logger.info "Push changes to origin master'"
        unless git_has_remote?(logger)
          logger.warn "  Directory '#{d}' has no remote at origin/master"
        end
        run_and_log('git push origin master', logger)
      end
    end
  rescue StandardError => e
    warn "!Error: #{e}"
    logger.error(e.full_message)
    exit(2)
  end
end
