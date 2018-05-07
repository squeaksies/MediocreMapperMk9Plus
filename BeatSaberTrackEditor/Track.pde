class Track extends GUIElement{
  // These are used to dermine how to handle notes places on the tracks
  private static final int NOTES = 0;
  private static final int EVENTS = 1;
  private static final int OBSTACLES = 2;
  
  HashMap<Float, GridBlock> gridBlocks;
  private int gridWidth = 0;
  private int gridHeight = 0;
  private int beatsPerBar = 8;
  private float bpm = 0;
  private boolean snapToGrid = true;
  private boolean trackDebug = false;
  private int trackType;
  
  int yStartingPosition = 0;
  
  Track(GUIElement parent, int gridWidth, int gridHeight, int beatsPerBar, int trackType){
    this.setParent(parent);
    println("track gridWidth: " + gridWidth);
    
    gridBlocks = new HashMap<Float, GridBlock>();
    this.gridWidth = gridWidth;
    this.gridHeight = gridHeight;
    this.beatsPerBar = beatsPerBar;
    this.trackType = trackType;
    
    this.setFillColor(color(#333333));
    this.setStrokeColor(color(#555555));
    this.setWidth(gridWidth);
    this.setHeight(Integer.MAX_VALUE);
    this.setY(-this.getHeight());
    
    yStartingPosition = this.getY();
  }
  
  // Convert X, Y cordinates (such as mouse click) to grid cordinates
  public float mouseCordToTime(int cordY){
    float cy = (float)cordY;
    float gridScale = (gridHeight * beatsPerBar);
    float val = 0;
    if(snapToGrid){
      val = ((cy) / gridScale);
      if(trackDebug) println("before snap time: " + val);
      int temp = floor(val * beatsPerBar);
      val = ((float)temp) / beatsPerBar;
      if(trackDebug) println("after snap time: " + val);
    }else{
      val = ((cy - gridHeight/2) / gridScale);
    }
    if(trackDebug) println("mouseCordToTime. cord: " + cordY + " = time: " + val);
    
    return val;
    
    //int cY = cordY;
    //return (height - cY) / gridSize;
    
    // time = (height - cordY) / beatsPerBar / bpm
    // time * bpm * beatsPerBar = (height - cordY)
    // time * bpm * beatsPerBar - height = -(cordY)
    // -((time * bpm * beatsPerBar) - height) = cordY
  }
  
  public int timeToCord(float time){
    //int val = (int)(-(time) * gridSize);
    
    int val = (int)(time * gridHeight * beatsPerBar);
    
    if(trackDebug) println("timeToCord. time: " + time + " = cord: " + val);
    return val;
  }
  
  public void addNoteMouseClick(int mx, int my, int type, int cutDirection){
    if(trackDebug) println();
    if(trackDebug) println("startingPosition: " + yStartingPosition);
    if(trackDebug) println("getY(): " + this.getY());
    
    float x = mouseCordToTime(height - my - (yStartingPosition - this.getY()));
    
    if(trackDebug) println("mouseCordToTime: " + x);
    this.addNote(x, type, cutDirection);
  }
  
  public void addNote(float time, int type, int cutDirection){
    if(trackDebug) println("Attempting to add note at time: " + time + ", type: " + type + ", cutDirection: " + cutDirection);
    if(trackDebug) println();
    
    Note n = new Note(this, this.getHeight() - timeToCord(time) - gridHeight, gridWidth, gridHeight, type, cutDirection, time);
    
    if(trackDebug) println("Adding note at Y position : " + n.getLocalY() + ", time " + n.getTime());
    
    gridBlocks.put(time, n);
    
    if(trackDebug) println("gridBlocks.size(): " + gridBlocks.size());
  }
  
  public void removeNoteMouseClick(int mx, int my){
    
    // Loop through the notes in this track and check for mouseclicks
    float key = Float.NaN;
    for (Float f: gridBlocks.keySet()) {
      Note block = (Note)gridBlocks.get(f);
      if(trackDebug) println("Checking block " + block + " at position " + block.getX() + ", " + block.getY());
      if(block.checkClicked(mx, my)){
        key = f;
        break;
      }
    }
    
    if(trackDebug) println("Deleting key :" + key);
    if(!Float.isNaN(key)){
      this.removeNote(key);
    }
  }
  
  public void removeNote(float time){
    gridBlocks.remove(time);
  }
  
  public void setBPM(float bpm){
    this.bpm = bpm;
  }
  
  public void setBeatsPerBar(int beatsPerBar){
    this.beatsPerBar = beatsPerBar;
  }
  
  public void setSnapToGrid(boolean snap){
    this.snapToGrid = snap;
  }
  
  public void display(){
    super.display();
    
    /*
    println("this.getWidth() " + this.getWidth());
    println("this.getHeight() " + this.getHeight());
    println("this.getX() " + this.getX());
    println("this.getY() " + this.getY());
    */
    
    for (Float f: gridBlocks.keySet()) {
      
      // Not sure if this cast is needed
      Note note = (Note)gridBlocks.get(f);
        note.display();
    }
  }
}
