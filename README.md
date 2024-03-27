# Testing Weak symbol lookup.

This repo tests and benchmarks various methods of "overriding" a C function from
a shared library. The methods benchmarked are:

* **DSO's with `LD_PRELOAD`**
  Compile the function definition in a shared object dynamically linked to the
  executable and override it by preloading an alternative SO with a competing
  function definiton

* **Weak references**
  Use `__attribute__((weak))` to declare a weak symbol in the executable. If the
  symbol exists at runtime, use it, if not, using a strongly defined alternative
  defined in the main exe
  
* **dlopen RTLD_NOW**
  Use `dlopen` to open an SO at runtime if it's available, and map pointers to
  the functions to struct members that we can call. When the symbols don't
  exist, map defaults provided in the main exe instead. This uses `RTLD_NOW` to
  preload all the symbols at boot.
  
* **dlopen RTLD_LAZY**
  Use `dlopen` to open an SO at runtime if it's available, and map pointers to
  the functions to struct members that we can call. When the symbols don't
  exist, map defaults provided in the main exe instead. This uses `RTLD_LAZY` to
  lookup symbols as they're used.
  
* **NOTE** I'm not confident in the benchmarking results yet between dlopen
  variants as there's only one symbol being looked up in our tests, which means
  that the difference between `RTLD_NOW` and `RTLD_LAZY` won't be as apparent.

## Instructions

Running the benchmarking script will compile all variants, test that they're
functioning correctly and run the benchmarks. 
## Benchmarking

Pay attention to the comments at
the top of the benchmark script for the steps I took to try and ensure system
stability during the benchmark.

All benchmarks were carried out on the following system:

```
distro: Fedora Linux 39 (Workstation Edition) x86_64 
kernel: 6.5.6-300.fc39.x86_64 
cpu: AMD Ryzen 5 3600 (6) @ 3.600GHz 
gpu: AMD ATI Radeon RX 470/480/570/570X/580/580X/590 
memory: 7447MiB / 15897MiB
```

### 1


```
❯ taskset -c 1,3 bundle exec ruby benchmark.rb
=== BUILDING DLOPEN-LAZY
=== BUILDING DLOPEN-NOW
=== BUILDING DSO-GC
=== BUILDING WEAK-SYMS

=== TESTING dlopen-lazy-default
=== TESTING dlopen-now-default
=== TESTING dso-gc-default
=== TESTING weak-syms-default
=== TESTING dlopen-lazy-override
=== TESTING dlopen-now-override
=== TESTING dso-gc-override
=== TESTING weak-syms-override

ruby 3.3.0 (2023-12-25 revision 5124f9ac75) [x86_64-linux]
Warming up --------------------------------------
 default-dlopen-lazy     7.000 i/100ms
  default-dlopen-now     7.000 i/100ms
      default-dso-gc     7.000 i/100ms
   default-weak-syms     8.000 i/100ms
Calculating -------------------------------------
 default-dlopen-lazy     76.339 (± 0.1%) i/s -    770.000 in  10.087085s
  default-dlopen-now     75.658 (± 0.2%) i/s -    763.000 in  10.086464s
      default-dso-gc     70.040 (± 0.4%) i/s -    707.000 in  10.098763s
   default-weak-syms     82.729 (± 0.2%) i/s -    832.000 in  10.058388s
                   with 95.0% confidence

Comparison:
   default-weak-syms:       82.7 i/s
 default-dlopen-lazy:       76.3 i/s - 1.08x  (± 0.00) slower
  default-dlopen-now:       75.7 i/s - 1.09x  (± 0.00) slower
      default-dso-gc:       70.0 i/s - 1.18x  (± 0.01) slower
                   with 95.0% confidence

ruby 3.3.0 (2023-12-25 revision 5124f9ac75) [x86_64-linux]
Warming up --------------------------------------
override-dlopen-lazy     6.000 i/100ms
 override-dlopen-now     6.000 i/100ms
     override-dso-gc     7.000 i/100ms
  override-weak-syms     6.000 i/100ms
Calculating -------------------------------------
override-dlopen-lazy     70.987 (± 0.3%) i/s -    714.000 in  10.062219s
 override-dlopen-now     70.119 (± 0.4%) i/s -    702.000 in  10.015652s
     override-dso-gc     69.993 (± 0.4%) i/s -    700.000 in  10.006132s
  override-weak-syms     70.881 (± 0.3%) i/s -    714.000 in  10.076312s
                   with 95.0% confidence

Comparison:
override-dlopen-lazy:       71.0 i/s
  override-weak-syms:       70.9 i/s - same-ish: difference falls within error
 override-dlopen-now:       70.1 i/s - 1.01x  (± 0.00) slower
     override-dso-gc:       70.0 i/s - 1.01x  (± 0.01) slower
                   with 95.0% confidence
```
  
### 2

```
❯ taskset -c 1,3 bundle exec ruby benchmark.rb
=== BUILDING DLOPEN-LAZY
=== BUILDING DLOPEN-NOW
=== BUILDING DSO-GC
=== BUILDING WEAK-SYMS

=== TESTING dlopen-lazy-default
=== TESTING dlopen-now-default
=== TESTING dso-gc-default
=== TESTING weak-syms-default
=== TESTING dlopen-lazy-override
=== TESTING dlopen-now-override
=== TESTING dso-gc-override
=== TESTING weak-syms-override

ruby 3.3.0 (2023-12-25 revision 5124f9ac75) [x86_64-linux]
Warming up --------------------------------------
 default-dlopen-lazy     7.000 i/100ms
  default-dlopen-now     7.000 i/100ms
      default-dso-gc     7.000 i/100ms
   default-weak-syms     8.000 i/100ms
Calculating -------------------------------------
 default-dlopen-lazy     76.211 (± 0.1%) i/s -    763.000 in  10.012465s
  default-dlopen-now     76.060 (± 0.1%) i/s -    763.000 in  10.032009s
      default-dso-gc     70.077 (± 0.2%) i/s -    707.000 in  10.090418s
   default-weak-syms     83.103 (± 0.1%) i/s -    832.000 in  10.012160s
                   with 95.0% confidence

Comparison:
   default-weak-syms:       83.1 i/s
 default-dlopen-lazy:       76.2 i/s - 1.09x  (± 0.00) slower
  default-dlopen-now:       76.1 i/s - 1.09x  (± 0.00) slower
      default-dso-gc:       70.1 i/s - 1.19x  (± 0.00) slower
                   with 95.0% confidence

ruby 3.3.0 (2023-12-25 revision 5124f9ac75) [x86_64-linux]
Warming up --------------------------------------
override-dlopen-lazy     6.000 i/100ms
 override-dlopen-now     7.000 i/100ms
     override-dso-gc     7.000 i/100ms
  override-weak-syms     7.000 i/100ms
Calculating -------------------------------------
override-dlopen-lazy     70.368 (± 0.3%) i/s -    708.000 in  10.065252s
 override-dlopen-now     70.942 (± 0.4%) i/s -    714.000 in  10.069457s
     override-dso-gc     71.285 (± 0.4%) i/s -    714.000 in  10.019751s
  override-weak-syms     71.246 (± 0.4%) i/s -    714.000 in  10.027109s
                   with 95.0% confidence

Comparison:
     override-dso-gc:       71.3 i/s
  override-weak-syms:       71.2 i/s - same-ish: difference falls within error
 override-dlopen-now:       70.9 i/s - same-ish: difference falls within error
override-dlopen-lazy:       70.4 i/s - 1.01x  (± 0.00) slower
                   with 95.0% confidence
```

## Initial observations.

* In the default case, compiling as a shared object is by far the slowest
  appraoch (~20% slowdown, compared to having static symbols), even when
  factoring in the `NULL` check used by the weak references approach.
* Using Weak symbols is consistently the fastest case, by nearly 10%.
* This sucks because it looks like weak symbols are essentially deprecated on
  macOS.
* There is basically no difference in performance in the case when the function
  is being overridden by a symbol in a DSO - all approaches perform as well as
  each other.
