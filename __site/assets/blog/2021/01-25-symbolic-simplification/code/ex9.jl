# This file was generated, do not modify it. # hide
using BenchmarkTools
slow = @benchmark $logdensity($post, $trace)