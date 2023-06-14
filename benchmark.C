#include <benchmark/benchmark.h>

#include <static_vector.hpp>

#include <memory>

void f( std::vector<int> * v );
void f( std::experimental::fixed_capacity_vector<int,1000000> * v );

void BM_vector(benchmark::State& state) {
    const unsigned int N = state.range(0);
    std::unique_ptr<int[]> a(new int[N]);
    for(size_t i = 0; i < N; ++i)
      a.get()[i] = std::rand();
    const int* b = a.get();

    for (auto _ : state) {
        int r=0;
	std::vector<int> v;
	v.reserve(N);
        for (size_t i = 0; i<N; ++i)
        {
	  v.push_back(b[i]);
        }
	f(&v);
        benchmark::DoNotOptimize(r += v.size());
    }
    state.SetItemsProcessed(N*state.iterations());
}

void BM_static_vector(benchmark::State& state) {
    // const unsigned int N = state.range(0);
    constexpr unsigned int N = 1e6;
    std::unique_ptr<int[]> a(new int[N]);
    for(size_t i = 0; i < N; ++i)
      a.get()[i] = std::rand();
    const int* b = a.get();

    for (auto _ : state) {
        int r=0;
	std::experimental::fixed_capacity_vector<int,N> v;
        for (size_t i = 0; i<N; ++i)
        {
	  v.push_back(b[i]);
        }
	f(&v);
        benchmark::DoNotOptimize(r += v.size());
    }
    state.SetItemsProcessed(N*state.iterations());
}

void BM_static_vector_push_back_check(benchmark::State& state) {
    // const unsigned int N = state.range(0);
    constexpr unsigned int N = 1e6;
    std::unique_ptr<int[]> a(new int[N]);
    for(size_t i = 0; i < N; ++i)
      a.get()[i] = std::rand();
    const int* b = a.get();

    for (auto _ : state) {
        int r=0;
	std::experimental::fixed_capacity_vector<int,N> v;
        for (size_t i = 0; i<N; ++i)
        {
	  v.push_back_check(b[i]);
        }
	f(&v);
        benchmark::DoNotOptimize(r += v.size());
    }
    state.SetItemsProcessed(N*state.iterations());
}

void BM_static_vector_push_back_unsafe(benchmark::State& state) {
    // const unsigned int N = state.range(0);
    constexpr unsigned int N = 1e6;
    std::unique_ptr<int[]> a(new int[N]);
    for(size_t i = 0; i < N; ++i)
      a.get()[i] = std::rand();
    const int* b = a.get();

    for (auto _ : state) {
        int r=0;
	std::experimental::fixed_capacity_vector<int,N> v;
        for (size_t i = 0; i<N; ++i)
        {
	  v.push_back_unsafe(b[i]);
        }
	f(&v);
        benchmark::DoNotOptimize(r += v.size());
    }
    state.SetItemsProcessed(N*state.iterations());
}

#define ARGS \
    ->Arg( long(1e6) )

BENCHMARK(BM_vector) ARGS;
BENCHMARK(BM_static_vector) ARGS;
BENCHMARK(BM_static_vector_push_back_check) ARGS;
BENCHMARK(BM_static_vector_push_back_unsafe) ARGS;

BENCHMARK_MAIN();
