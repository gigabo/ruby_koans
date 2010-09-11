require File.expand_path(File.dirname(__FILE__) + '/edgecase')

C = "top level"

class AboutConstants < EdgeCase::Koan

  C = "nested"

  def test_nested_constants_may_also_be_referenced_with_relative_paths
    assert_equal "nested", C
  end

  def test_top_level_constants_are_referenced_by_double_colons
    assert_equal "top level", ::C
  end

  def test_nested_constants_are_referenced_by_their_complete_path
    assert_equal "nested", AboutConstants::C
    assert_equal "nested", ::AboutConstants::C
  end

  # ------------------------------------------------------------------

  class Animal
    LEGS = 4
    def legs_in_animal
      LEGS
    end

    class NestedAnimal
      def legs_in_nested_animal
        LEGS
      end
    end
  end

  def test_nested_classes_inherit_constants_from_enclosing_classes
    assert_equal 4, Animal::NestedAnimal.new.legs_in_nested_animal
  end

  # ------------------------------------------------------------------

  class Reptile < Animal
    def legs_in_reptile
      LEGS
    end
  end

  def test_subclasses_inherit_constants_from_parent_classes
    assert_equal 4, Reptile.new.legs_in_reptile
  end

  # ------------------------------------------------------------------

  class MyAnimals
    LEGS = 2

    class Bird < Animal
      def legs_in_bird
        LEGS
      end
    end
  end

  def test_who_wins_with_both_nested_and_inherited_constants
    assert_equal 2, MyAnimals::Bird.new.legs_in_bird
  end

  # QUESTION: Which has precedence: The constant in the lexical scope,
  # or the constant from the inheritance heirarachy?

  # The constant in the lexical scope has precedence over the constant
  # from the inheritance hierarchy.  That's good to know.
  # ------------------------------------------------------------------

  class MyAnimals::Oyster < Animal
    def legs_in_oyster
      LEGS
    end
  end

  def test_who_wins_with_explicit_scoping_on_class_definition
    assert_equal 4, MyAnimals::Oyster.new.legs_in_oyster
  end

  # QUESTION: Now Which has precedence: The constant in the lexical
  # scope, or the constant from the inheritance heirarachy?  Why is it
  # different than the previous answer?

  # OK, so I tested this out a little bit in a separate script, and it
  # looks like MyAnimals::Oyster isn't in a nested lexical scope relative
  # to the previous definition of MyAnimals here.  If LEGS weren't inherited
  # via the class hierarchy, then it would be uninitialized, and we'd be
  # testing with an assert_raise(NameError).
  #
  # The nested lexical scope from the previous example (MyAnimals::Bird)
  # seems to be  different from the declaration of a class in a nested class
  # namespace.  That might be worth adding another test for:

  class Outer
    OUT_OF_REACH = "Can't touch this"
  end

  class Outer::Inner
    def grab_outer_guts
      OUT_OF_REACH
    end
  end

  def test_with_just_a_nested_class_namespace
    assert_raise(NameError) do
      Outer::Inner.new.grab_outer_guts
    end
  end
end
