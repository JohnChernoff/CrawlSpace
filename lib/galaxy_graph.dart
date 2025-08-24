import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:space_fugue/system.dart';
import 'fugue_model.dart';

class SystemNode {
  final System system;
  final Node node;
  SystemNode(this.system) : node = Node.Id(system.name);
}

class GalaxyGraph {
  final Graph graph = Graph();
  final List<SystemNode> systemNodes;
  SystemNode? byNode(Node node) => systemNodes.firstWhereOrNull((sn) => sn.node == node);
  SystemNode? bySystem(System s) => systemNodes.firstWhereOrNull((sn) => sn.system == s);

  GalaxyGraph(FugueModel game) : systemNodes =  game.galaxy.systems.map((s) => SystemNode(s)).toList() {
    for (final system in game.galaxy.systems) {
      final node = bySystem(system)!.node;
      graph.addNode(node); //print("Added Node: $node");
    }

    for (final system in game.galaxy.systems) {
      final fromNode = bySystem(system)!.node;
      for (final link in system.links) {
        final toNode = bySystem(link)!.node;
        if (!graph.edges.any((e) =>
        (e.source == fromNode && e.destination == toNode) ||
            (e.source == toNode && e.destination == fromNode))) {
          graph.addEdge(fromNode, toNode, paint: Paint()..color = Colors.yellow); //print("Added Edge: $fromNode <-> $toNode");
        }
      }
    }
    print("Finished building graph");
  }

  List<System>? shortestPath(System start, System goal) {
    List<Node>? nPath = shortestNodePath(bySystem(start)!.node, bySystem(goal)!.node);
    return nPath?.map((node) => byNode(node)!.system).toList();
  }

  List<Node>? shortestNodePath(Node start, Node goal) {
    if (start == goal) return [start];

    final visited = <Node>{};
    final parentMap = <Node, Node>{};
    final queue = <Node>[];

    queue.add(start);
    visited.add(start);

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);

      for (final edge in graph.edges) {
        Node? neighbor;
        if (edge.source == current) {
          neighbor = edge.destination;
        } else if (edge.destination == current) {
          neighbor = edge.source;
        }

        if (neighbor != null && !visited.contains(neighbor)) {
          visited.add(neighbor);
          parentMap[neighbor] = current;

          if (neighbor == goal) {
            // Backtrack to build path
            final path = <Node>[];
            Node? p = goal;
            while (p != null) {
              path.insert(0, p);
              p = parentMap[p];
            }
            return path;
          }

          queue.add(neighbor);
        }
      }
    }
    // No path found
    return null;
  }
}
