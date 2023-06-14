#include <vector>
#include <static_vector.hpp>

void f( std::vector<int> * v ) {
}
void f( std::experimental::fixed_capacity_vector<int,1000000> * v ) {}
