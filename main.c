#define u32 unsigned int

void spindelay(int max);

int main() {
  // divide the clock by 32
  *(u32*)(0xbf100040) = 0x8000841f;

  // GPIO(FORCE_DFU) pulse loop
  while (1) {
    *(u32*)(0xbfa00068) = 0x213;
    spindelay(1000);
    *(u32*)(0xbfa00068) = 0x212;
    spindelay(1000);
  }
}

void spindelay(int max) {
  volatile int i;
  for (i=0;i<max;i++);
}
