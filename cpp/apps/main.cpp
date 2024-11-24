#include "main.hpp"
#include <iostream>
#include <my_library/lib.hpp>

auto main() -> int {
    std::cout << "Hello, 2 + 3 = " << add(2, 3) << std::endl;
}
