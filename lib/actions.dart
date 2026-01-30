enum ActionType {
  movement(10,1,1,false),
  sector(32,16,1,false),
  planet(24,24,1,true),
  planetLand(36,50,2,true),
  planetLaunch(16,1,1,false),
  planetOrbit(50,1,1,false),
  warp(8,0,0,false),
  energyScoop(72,0,0,false),
  piracy(100,100,10,false);
  final int baseAuts, risk, heat;
  final bool dna;
  const ActionType(this.baseAuts,this.risk, this.heat, this.dna);
}

