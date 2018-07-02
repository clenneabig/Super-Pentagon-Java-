import java.util.Collections;
import java.util.List;
//This loads the highscores from a file
class HighScore {
  List<Float> scores = new ArrayList<Float>();
  HighScore(String file) {
    String[] scoresLoaded = loadStrings(file);
    for (String score : scoresLoaded) {
      scores.add(Float.parseFloat(score));
    }
    sortTimes();
  }
  
  //This sorts the scores from highest to lowest
  void sortTimes() {
    Collections.sort(scores, Collections.reverseOrder());
  }
  
  //This only adds a time to the file if it is at least greater than the smallest time in the file
  void addTime(float time, String file) {
    scores.add(time);
    sortTimes();
    scores = scores.subList(0,Math.min(10,scores.size()));
    saveTimes(file);
  }
  
  //This saves the times to a file
  void saveTimes(String file) {
    String[] times = new String[scores.size()];
    for(int i = 0; i < scores.size(); i++) {
      times[i] = scores.get(i) + "";
    }
    saveStrings("data\\"+file, times);
  }
}
