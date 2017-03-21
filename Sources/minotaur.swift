import LogicKit

let zero = Value (0)

func succ (_ of: Term) -> Map {
    return ["succ": of]
}

func toNat (_ n : Int) -> Term {
    var result : Term = zero
    for _ in 1...n {
        result = succ(result)
    }
    return result
}

struct Position : Equatable, CustomStringConvertible {
    let x : Int
    let y : Int

    var description: String {
        return "\(self.x):\(self.y)"
    }

    static func ==(lhs: Position, rhs: Position) -> Bool {
      return lhs.x == rhs.x && lhs.y == rhs.y
    }

}


// rooms are numbered:
// x:1,y:1 ... x:n,y:1
// ...             ...
// x:1,y:m ... x:n,y:m
func room (_ x: Int, _ y: Int) -> Term {
  return Value (Position (x: x, y: y))
}

func doors (from: Term, to: Term) -> Goal {
  // utilisation du pdf pour obtenir ces co-ordonnées
  return (from === room(2,1) && to === room(1,1))
      || (from === room(3,1) && to === room(2,1))
      || (from === room(4,1) && to === room(3,1))
      || (from === room(1,2) && to === room(1,1))
      || (from === room(1,2) && to === room(2,2))
      || (from === room(2,2) && to === room(3,2))
      || (from === room(3,2) && to === room(4,2))
      || (from === room(3,2) && to === room(3,3))
      || (from === room(4,2) && to === room(4,1))
      || (from === room(4,2) && to === room(4,3))
      || (from === room(1,3) && to === room(1,2))
      || (from === room(2,3) && to === room(1,3))
      || (from === room(2,3) && to === room(2,2))
      || (from === room(1,4) && to === room(1,3))
      || (from === room(2,4) && to === room(2,3))
      || (from === room(3,4) && to === room(3,3))
      || (from === room(3,4) && to === room(2,4))
      || (from === room(4,4) && to === room(3,4))

}

func entrance (location: Term) -> Goal {
    // utilisation du pdf pour obtenir ces co-ordonnées
    return (location === room(1,4)) || (location === room(4,4))
}

func exit (location: Term) -> Goal {
    // utilisation du pdf pour obtenir ces co-ordonnées
    return (location === room(1,1)) || (location === room(4,3))
}

func minotaur (location: Term) -> Goal {
    // utilisation du pdf pour obtenir ces co-ordonnées
    return (location === room(3,2))
}

func path (from: Term, to: Term, through: Term) -> Goal {
  /*
  Cas de fin de condition: on va de from à to par une case qui est through
  Dans le cas ou le through est une liste de case, on utlilise le fresh pour
  extraire le premier élément et tester si on peut aller du from à cet élement
  et on rappelle la fonction path depuis cette case la jusqu'au "to" avec le reste
  des élements de through.
  */
  return ((doors(from: from, to: to)) && (through === List.empty)) ||

          (delayed (fresh { x in fresh { y in
            ((through === List.cons(x, y)) && (doors(from: from, to: x))
          && (path(from: x, to: to, through: y))) }}))
}

/* J'ai créer une fonction parallèle pour soustraire un nombre du level qui est
le premier cas */
func battery_parallele(through: Term, level: Term) -> Goal {
  return  (through === List.empty) ||
          delayed (fresh { x in fresh { y in fresh { z in fresh { a in
            /* on enleve un element du through et de level et on rappelle la fonction */
            (through === List.cons(x, y)) &&
            (level ≡ succ(z)) &&
            /* pour éviter d'appeller battery_parallele avec level = zero, on
             vérifie qu'il existe bien un nombre derriere */
            (z === succ(a)) &&
            (battery_parallele(through:y, level: z))

          }}}})
}


func battery (through: Term, level: Term) -> Goal {
    return  delayed (fresh { x in
      /* On enlève le premier element pour la premiere case et on appelle la
      fonction avec battery_parallele avec cela*/
            (level === succ(x)) &&
            battery_parallele(through: through, level: x)

    })
}

/* Cette fonction retourne un Goal, on vérifie si le minotaur appartient au path */
func is_Minotaur(through: Term) -> Goal {
  return delayed ( fresh{ x in fresh { y in
        (through === List.cons(x, y)) &&
        /* on met un ou ci-dessous car il suffit que le minotaur apparaissent une fois
           au moins
        */
        (minotaur(location: x) || is_Minotaur(through: y))
  }})
}

func winning (through: Term, level: Term) -> Goal {
  return battery(through: through, level: level) && // on check si on a assez de batterie pour faire le parcours
         is_Minotaur(through: through) && // si le minotaur fait parti du parcours
         delayed ( fresh { x in fresh { y in
           /* on vérifie s'il existe x et y tel qu'il existe un chemin qui
         commence à x et qui va à y par through qui est le parcours entré */
              entrance(location: x) &&
              exit(location: y) &&
              path(from: x, to: y, through: through)
          }})

}
