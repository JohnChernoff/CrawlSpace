import 'dart:math';

import 'package:space_fugue/actions.dart';
import 'package:space_fugue/system.dart';

enum AttribType {
  int,wis,str,dex,cha,con
}

enum SkillType {
  engineering,piloting,medicine,communications,combat
}

class Pilot {
  String name;
  System system;
  Map<AttribType,int> attributes = {};
  Map<SkillType,int> skills = {};
  int hp;
  int auCooldown = 0;
  ActionType? lastAct;
  bool hostile;
  bool get ready => auCooldown == 0;
  void tick() => auCooldown = max(0,auCooldown - 1);
  Pilot(this.name,this.system,{this.hp = 32, this.hostile = true});

}