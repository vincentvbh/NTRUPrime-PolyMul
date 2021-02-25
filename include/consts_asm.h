#ifndef ASM_H
#define ASM_H
#include <stdint.h>
// Z_{4591}/(X^1620-1)
#define PARAMS_M 1620


static int16_t omegas_asm[265] = {1, 311, 310, 1, 1, 3, 933, 930, 9, 81, 9, -1792, -1801, 81, 1970, 27, -785, -812, 729, -1115, 81, 2236, 2155, 1970, 1505, 243, 2117, 1874, -634, -2052, 729, 1760, 1031, -1115, -936, 2187, 689, -1498, -853, 2231, 1970, 2067, 97, 1505, 1662, 1319, 1610, 291, -228, 1483, -634, 239, 873, -2052, 757, -1902, 717, -1972, -104, 1634, -1115, 2151, -1325, -936, -785, 1246, 1862, 616, 758, 689, -853, 995, 1848, 2231, 717, 2032, -1606, 953, 1715, -1606, 1505, -227, -1732, 1662, -1538, -76, -681, -605, 1185, -621, -228, -2043, -1815, 1483, 200, -684, -1538, -854, -426, -2164, -2052, -23, 2029, 757, -826, -1565, -69, 1496, 2222, 1959, -104, -207, -103, 1634, -2006, -312, -621, -309, 933, -1801, -936, -1863, -927, -785, 1031, 1783, -998, 1810, 2117, 873, 758, 1597, 839, 689, 1848, 2274, 200, -2074, 1610, -1815, 2231, 600, -1631, 717, -103, 2102, 1800, -302, 1862, 839, 1715, 809, -906, -1606, -906, 554, -2164, 1873, -681, 70, 1662, -1901, 1028, -1538, 1079, 395, -1112, -1507, -69, 170, 1185, 1255, 70, -621, -3, -1036, -826, 210, -998, -243, 1483, 2113, 630, 200, -1319, -142, 1748, 1890, 1800, -1246, -426, 653, 1079, -2164, 76, -1278, 1959, -1354, -1112, 1565, 757, 1286, 529, -826, -1783, 2271, -733, 1587, 1748, -2102, 2222, -2199, 170, 1959, -395, 2075, -2006, 510, -733, 142, 1634, -1427, 1530, -2006, -2271, 1, 1, 1715, -1606, -1606, -906, 1, 1, 729, -1115, 1483, 200, -69, 170, -228, 1483, -1115, -936, 2222, 1959, 200, -1319, 1483, 200, -228, 1483, -785, 1031, -1112, 1565, 1610, -1815, -936, -785, 1610, -1815, 1959, -395, 200, -1319} ;

static int16_t invomegas_asm[266] = {1, 1, 1, 1, 2074, -291, -2113, 2043, -291, 2043, -2274, 630, 1354, 1507, 2074, -1496, -1496, 2199, 2043, 1278, 812, -1760, -1319, -1325, 1507, -1496, -291, 2199, -953, -809, -311, -2032, 2199, 1278, 630, -1112, -510, -1587, 1354, -1890, -1810, -1874, -809, -239, 1498, -995, 1565, -1631, -1890, 302, -1496, -616, 854, -653, -2151, -554, -930, 1792, -27, 2155, -1873, 605, 812, -1255, -616, -1597, 1278, -2187, -1286, 1036, -906, -998, -1587, -1890, 1507, 302, 309, -930, 1863, 1792, -1874, -239, -2032, 2029, -210, -1810, -953, -1874, 605, -1255, -1760, 312, 1427, -2075, 170, -733, 302, -616, 2199, -1597, 1972, 207, -395, 1530, -653, -554, -927, -681, -1530, -510, -170, -1587, -839, 1498, 1112, -995, -97, 227, 936, 1028, -1079, -1873, 927, 605, -2029, -1286, 1606, 1036, 1801, -2236, -729, 97, -1028, 854, -1031, -653, -1848, -600, -2222, 1902, 733, 142, -1507, 1800, -170, 1354, -630, 1507, 927, 812, -200, -1760, -1031, -2151, 228, -927, -630, 2074, 1815, -291, 1815, -2113, -1610, -2274, -310, -311, -1, 310, 906, -953, -310, -809, 1325, 1863, -1483, -27, -1959, -395, -2074, -69, -529, -210, 906, -1810, 103, 1427, 69, -2075, -2155, -2067, 1115, -1732, -70, 309, 1325, -930, 1732, 1901, 785, 684, 2006, -2271, -1354, 1748, 1631, 1972, -1959, 207, -873, 23, -1715, 529, -1748, -2102, 1496, 1862, 1, 1, -953, -809, -809, -2032, 1, 1, -210, -1810, -1874, -239, 23, 529, -953, -809, -1810, -1874, -1286, 1036, -239, 2029, -809, -2032, -529, -210, -873, 23, 998, -243, 906, -953, 906, -953, -310, -311, 1606, -906, -310, -311, -2029, -1286, 826, -1783, -2117, 873, 1606, -906, -310, -311} ;

static int16_t bromegas_asm[270] = {1, 1610, -1815, -2274, -2113, -228, 200, 630, -311, -291, 1483, 310, -1319, 2043, 2074, 729, -1606, -927, -395, 2199, -936, -1112, 170, -1760, -953, 2222, 1031, -2032, 1863, 1507, -1115, -69, -906, 1278, 812, 1715, 1959, -27, -2151, -1496, -785, -1325, 1565, -809, 1354, 9, 717, 2029, -2102, -653, -2052, 1800, 1079, 1792, 1972, -426, -1801, 1902, 23, 302, 1970, -681, 839, 1036, 1427, 758, -826, 1530, -2067, 605, 1634, 97, 76, -1597, -210, -853, -621, 1028, -2271, -1874, 1662, -733, -243, -995, 309, 2117, 1848, 312, 1901, -1587, 81, 1862, -103, -554, -1286, -104, -2164, 529, -2236, -616, 757, 2155, -1246, 207, -1873, -634, -1538, -1631, 142, -930, 2231, 1748, -3, -239, 854, 933, 873, 684, -600, -1890, 1505, -998, 70, -2075, 1498, 1185, -2006, -2187, 227, -1810, 689, -1732, -1783, -1255, -510, 3, 239, -854, -2231, -1748, -684, 600, 1890, -933, -873, -142, 930, 634, 1538, 1631, 2187, -227, 1810, -1185, 2006, 1783, 1255, 510, -689, 1732, 2075, -1498, -1505, 998, -70, 1246, -207, 1873, -757, -2155, 554, 1286, -81, -1862, 103, 2236, 616, 104, 2164, -529, 27, 2151, 1496, -1715, -1959, -1565, 809, -1354, 785, 1325, -1278, -812, 1115, 69, 906, 1319, -2043, -2074, -1483, -310, 2274, 2113, -1, -1610, 1815, 311, 291, 228, -200, -630, 2032, -1863, -1507, -2222, -1031, 395, -2199, -729, 1606, 927, 1760, 953, 936, 1112, -170, 243, 995, -309, -1662, 733, -312, -1901, 1587, -2117, -1848, 2271, 1874, 853, 621, -1028, -1902, -23, -302, 426, 1801, 2102, 653, -9, -717, -2029, -1792, -1972, 2052, -1800, -1079, -76, 1597, 210, -1634, -97, -1036, -1427, -1970, 681, -839, 2067, -605, -758, 826, -1530} ;
#endif