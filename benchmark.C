#include <benchmark/benchmark.h>

#include <memory>

void f( std::vector<int> * v );

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

#define ARGS \
    ->Arg( long(1e6) )

BENCHMARK(BM_vector) ARGS;

BENCHMARK_MAIN();
