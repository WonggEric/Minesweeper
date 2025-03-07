import de.bezier.guido.*;

private final static int dimensions = 20;
private final static int NUM_ROWS = dimensions, NUM_COLS = dimensions;
private MSButton[][] buttons;
private ArrayList<MSButton> mines = new ArrayList<MSButton>();
private final static int NUM_MINES = (int) (NUM_ROWS * NUM_COLS * 0.16);
private final static int[] r = {-1, -1, -1, 0, 0, 1, 1, 1};
private final static int[] c = {-1, 0, 1, -1, 1, -1, 0, 1};
private boolean gameOver = false;
private boolean gameWon = false;
private boolean firstClick = false;

public void setup() {
  size(400, 450);
  textAlign(CENTER, CENTER);
  Interactive.make(this);
  buttons = new MSButton[NUM_ROWS][NUM_COLS];
  for (int i = 0; i < NUM_ROWS; i++) {
    for (int j = 0; j < NUM_COLS; j++) {
      buttons[i][j] = new MSButton(i, j);
    }
  }
}

public void setMines(int row, int col) {
  if (firstClick == true) {  
    while (mines.size() < NUM_MINES) { 
      int r = (int) (Math.random() * NUM_ROWS);  
      int c = (int) (Math.random() * NUM_COLS); 
      MSButton button = buttons[r][c];
      if (!mines.contains(button) && (r != row || c != col)) { 
        mines.add(button);
      }
    }
  }
}

public void draw() {
  background(128, 128, 128);
  if (gameOver) {
    displayLosingMessage();
  } else if (gameWon) {
    displayWinningMessage();
  } else {
    return;
  }
}

public boolean isValid(int row, int col) {
  return row >= 0 && row < NUM_ROWS && col >= 0 && col < NUM_COLS;
}

public int countMines(int row, int col) {
  int numMines = 0;
  for (int i = 0; i < 8; i++) {
    int newRow = row + r[i];
    int newCol = col + c[i];
    if (isValid(newRow, newCol) && mines.contains(buttons[newRow][newCol])) {
      numMines++;
    }
  }
  return numMines;
}

public void revealAllMines() {
  for (int i = 0; i < mines.size(); i++) {
    MSButton mine = mines.get(i);
    mine.clicked = true;
  }
}

public void displayWinningMessage() {
  fill(0);
  text("WINNER", 200, 25);
}

public void displayLosingMessage() {
  fill(0);
  text("TRY AGAIN", 200, 25);
  revealAllMines();
}

public boolean isWon() {
  for (int i = 0; i < NUM_ROWS; i++) {
    for (int j = 0; j < NUM_COLS; j++) {
      MSButton button = buttons[i][j];
      if (mines.contains(button) && !button.isFlagged()) {
        return false;
      }
      if (!mines.contains(button) && !button.clicked) {
        return false;
      }
    }
  }
  return true;
}

public class MSButton {
  private int myRow, myCol;
  private float x, y, width, height;
  private boolean clicked, flagged;
  private String myLabel;

  public MSButton(int row, int col) {
    width = 400 / (float) NUM_COLS;
    height = 400 / (float) NUM_ROWS;
    myRow = row;
    myCol = col;
    x = myCol * width;
    y = myRow * height+50;
    myLabel = "";
    flagged = clicked = false;
    Interactive.add(this);
  }

  public void mousePressed() {
    if (gameOver || gameWon) {
      return;
    }
    if (mouseButton == RIGHT) {
      flagged = !flagged;
      if (!flagged) {
        clicked = false;
      }
    } else {
      if (!clicked) {
        if (!firstClick) {
          firstClick = true;
          setMines(myRow, myCol);
        }
        clicked = true;
        if (mines.contains(this)) {
          gameOver = true;
        } else {
          int mineCount = countMines(myRow, myCol);
          if (mineCount > 0) {
            textSize(20);
            setLabel(mineCount);
          } else {
            for (int i = 0; i < 8; i++) {
              int newRow = myRow + r[i];
              int newCol = myCol + c[i];
              if (isValid(newRow, newCol) && !buttons[newRow][newCol].clicked && !mines.contains(buttons[newRow][newCol])) {
                buttons[newRow][newCol].mousePressed();
              }
            }
          }
        }
        if (isWon()) {
          gameWon = true;
        }
      }
    }
  }

  public void draw() {
    if (flagged) {
      fill(0, 0, 0);
    } else if (clicked && mines.contains(this)) {
      fill(255, 0, 0);
      stroke(255, 0, 0);
      strokeWeight(1);
    } else if (clicked) {
      fill(192, 192, 192);
      stroke(64, 64, 64);
      strokeWeight(1);
    } else {
      fill(120, 120, 120);
      stroke(255);
      strokeWeight(1);
      rect(x-1, y-1, width, height+50);
    }

    rect(x, y, width, height+50);
    if (!myLabel.equals("")) {
      if (myLabel.equals("1")) {
        fill(0, 0, 255);
      } else if (myLabel.equals("2")) {
        fill(0, 128, 0);
      } else if (myLabel.equals("3")) {
        fill(255, 0, 0);
      } else if (myLabel.equals("4")) {
        fill(0, 0, 128);
      }
      text(myLabel, x + width / 2, y + height / 2);
    }
  }

  public void setLabel(String newLabel) {
    myLabel = newLabel;
  }

  public void setLabel(int newLabel) {
    myLabel = "" + newLabel;
  }

  public boolean isFlagged() {
    return flagged;
  }
}

