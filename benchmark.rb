require 'benchmark/ips'
require 'pathname'
require 'open3'

## This script should be run on as stable a system as possible. This means bare
## metal, preferably not battery powered. For Linux I have also done these
## things

# Disable hyper-threading/other SMT mechanisms
# sudo bash -c 'echo off > /sys/devices/system/cpu/smt/control'

# Run with CPU isolation
# taskset -c 1,3 bundle exec ruby benchmark.rb

# Disable Address space layout randomisation
# sudo bash -c 'echo 0 >| /proc/sys/kernel/randomize_va_space'

ITERATIONS=500_000

experiments = Pathname.glob("#{__dir__}/*")
  .select(&:directory?)
  .map(&:basename)
  .map(&:to_s)

experiment_commands = {
  default: {},
  override: {}
}

experiments.each do |experiment|
  puts "=== BUILDING #{experiment.upcase}\n"
  system("make -C #{experiment} clean default CFLAGS=-DGC_TEST_ITERS=#{ITERATIONS}> /dev/null");

  env = case experiment
  when /dlopen/
    "RUBY_GC_PATH=#{__dir__}/#{experiment}/libgc.so"
  when "dso-gc"
    "LD_PRELOAD=#{__dir__}/#{experiment}/override/libgc.so"
  else
    "LD_PRELOAD=#{__dir__}/#{experiment}/libgc.so"
  end
  
  experiment_commands[:default][experiment] = "./#{experiment}/main"
  experiment_commands[:override][experiment] = "#{env} ./#{experiment}/main"
end

puts ""

experiment_commands.each_pair do |branch, experiments|
  experiments.each_pair do |name, command|
    puts "=== TESTING #{name}-#{branch}"
    stdout, status = Open3.capture2(command)

    unless stdout.match(/#{branch.to_s.capitalize}/)
      raise StandardError, <<~ERROR
        #{name}-#{branch} does not match expected output.
        \t command:\t\t#{command}
        \t actual:\t\t#{stdout}
        \t expected:\t\t#{branch.to_s.capitalize}
      ERROR
    end
  end
end

puts ""

[:default, :override].each do |branch|
  Benchmark.ips do |x|
    x.time = 10
    x.warmup = 2
    x.stats = :bootstrap
    x.confidence = 95
    
    experiment_commands[branch].each_pair do |name, command|
      x.report("#{branch}-#{name}") {
        system("#{command} > /dev/null")
      }
    end
    x.compare!
  end
end

