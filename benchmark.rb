require 'benchmark/ips'
require 'open3'

ITERATIONS=50000

experiments = %w{
  weak-syms
  dlopen
}
experiment_commands = {
  default: {},
  override: {}
}

experiments.each do |experiment|
  puts "=== BUILDING #{experiment.upcase}\n"
  system("make -C #{experiment} clean default CFLAGS=-DGC_TEST_ITERS=#{ITERATIONS}> /dev/null");

  env = case experiment
  when "dlopen"
    "RUBY_GC_PATH=#{__dir__}/#{experiment}/libgc.so"
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

