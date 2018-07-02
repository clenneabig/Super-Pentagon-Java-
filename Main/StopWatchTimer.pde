class StopWatchTimer {
  int startTime = 0;
  int stopTime = 0;
  boolean running = false; 

  void start() {
    startTime = millis();
    running = true;
  }

  void stop() {
    stopTime = millis();
    running = false;
  }

  int getElapsedTime() {
    int elapsed;
    if (running) {
      elapsed = (millis() - startTime);
    } else {
      elapsed = (stopTime - startTime);
    }
    return elapsed;
  }
  
  //This gets the elapsed time in seconds
  float second() {
    return (getElapsedTime() / 1000.0);
  }
}