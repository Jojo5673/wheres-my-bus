class LandingStore {
  int count = 0;

  void increment() {
    count++;
    print("New count: $count");
  }

  int getCount(){
    return count;
  }
}