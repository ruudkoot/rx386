extern int _consoleout(char c);

int c_entry() {
  _consoleout('A');
  _consoleout('B');
  _consoleout('C');
  _consoleout('D');
  return 0;
}