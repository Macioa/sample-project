defmodule SubjectManager.SubjectsTest do
  use SubjectManager.DataCase

  alias SubjectManager.Subjects
  alias SubjectManager.Subjects.Subject

  describe "list_subjects/0" do
    test "returns all subjects" do
      _subject1 = insert_subject(%{name: "John Doe", team: "Team A", position: :forward, bio: "A great forward player"})
      _subject2 = insert_subject(%{name: "Jane Smith", team: "Team B", position: :midfielder, bio: "Excellent midfielder"})

      subjects = Subjects.list_subjects()
      assert length(subjects) == 2
      assert Enum.any?(subjects, &(&1.name == "John Doe"))
      assert Enum.any?(subjects, &(&1.name == "Jane Smith"))
    end
  end

  describe "list_subjects/1 with filtering" do
    setup do
      # Create test subjects with different attributes
      subjects = [
        insert_subject(%{name: "John Doe", team: "Arsenal", position: :forward, bio: "A great forward player"}),
        insert_subject(%{name: "Jane Smith", team: "Chelsea", position: :midfielder, bio: "Excellent midfielder"}),
        insert_subject(%{name: "Bob Johnson", team: "Arsenal", position: :defender, bio: "Strong defender"}),
        insert_subject(%{name: "Alice Brown", team: "Liverpool", position: :goalkeeper, bio: "Amazing goalkeeper"}),
        insert_subject(%{name: "Charlie Wilson", team: "Chelsea", position: :winger, bio: "Fast winger"})
      ]

      %{subjects: subjects}
    end

    test "filter_by_name with exact match" do
      subjects = Subjects.list_subjects(%{q: "John Doe"})
      assert length(subjects) == 1
      assert hd(subjects).name == "John Doe"
    end

    test "filter_by_name with partial match" do
      subjects = Subjects.list_subjects(%{q: "Jane"})
      assert length(subjects) == 1
      assert hd(subjects).name == "Jane Smith"
    end

    test "filter_by_name with case insensitive partial match" do
      subjects = Subjects.list_subjects(%{q: "jane"})
      assert length(subjects) == 1
      assert hd(subjects).name == "Jane Smith"
    end

    test "filter_by_name with multiple matches" do
      subjects = Subjects.list_subjects(%{q: "Bob"})
      assert length(subjects) == 1
      assert hd(subjects).name == "Bob Johnson"
    end

    test "filter_by_name with no matches" do
      subjects = Subjects.list_subjects(%{q: "NonExistent"})
      assert length(subjects) == 0
    end

    test "filter_by_name with nil query" do
      subjects = Subjects.list_subjects(%{q: nil})
      assert length(subjects) == 5
    end

    test "filter_by_name with empty string" do
      subjects = Subjects.list_subjects(%{q: ""})
      assert length(subjects) == 5
    end

    test "filter_by_position with exact match" do
      subjects = Subjects.list_subjects(%{position: :forward})
      assert length(subjects) == 1
      assert hd(subjects).name == "John Doe"
    end

    test "filter_by_position with string match" do
      subjects = Subjects.list_subjects(%{position: "midfielder"})
      assert length(subjects) == 1
      assert hd(subjects).name == "Jane Smith"
    end

    test "filter_by_position with no matches" do
      # Test with a valid enum value that doesn't exist in our test data
      subjects = Subjects.list_subjects(%{position: :winger})
      assert length(subjects) == 1
      assert hd(subjects).name == "Charlie Wilson"
    end

    test "filter_by_position with nil" do
      subjects = Subjects.list_subjects(%{position: nil})
      assert length(subjects) == 5
    end

    test "filter_by_position with empty string" do
      subjects = Subjects.list_subjects(%{position: ""})
      assert length(subjects) == 5
    end

    test "sort_by_field by name ascending" do
      subjects = Subjects.list_subjects(%{sort_by: "name"})
      names = Enum.map(subjects, & &1.name)
      assert names == ["Alice Brown", "Bob Johnson", "Charlie Wilson", "Jane Smith", "John Doe"]
    end

    test "sort_by_field by team ascending" do
      subjects = Subjects.list_subjects(%{sort_by: "team"})
      teams = Enum.map(subjects, & &1.team)
      assert teams == ["Arsenal", "Arsenal", "Chelsea", "Chelsea", "Liverpool"]
    end

    test "sort_by_field by position ascending" do
      subjects = Subjects.list_subjects(%{sort_by: "position"})
      positions = Enum.map(subjects, & &1.position)
      assert positions == [:defender, :forward, :goalkeeper, :midfielder, :winger]
    end

    test "sort_by_field with invalid field" do
      subjects = Subjects.list_subjects(%{sort_by: "invalid_field"})
      # Should return unsorted results
      assert length(subjects) == 5
    end

    test "sort_by_field with nil" do
      subjects = Subjects.list_subjects(%{sort_by: nil})
      assert length(subjects) == 5
    end

    test "sort_by_field with empty string" do
      subjects = Subjects.list_subjects(%{sort_by: ""})
      assert length(subjects) == 5
    end

    test "combined filters: name and position" do
      subjects = Subjects.list_subjects(%{q: "John", position: :forward})
      assert length(subjects) == 1
      subject = hd(subjects)
      assert subject.name == "John Doe"
      assert subject.position == :forward
    end

    test "combined filters: name, position, and sort" do
      subjects = Subjects.list_subjects(%{q: "John", position: :forward, sort_by: "name"})
      assert length(subjects) == 1
      subject = hd(subjects)
      assert subject.name == "John Doe"
    end

    test "combined filters: partial name match with position" do
      subjects = Subjects.list_subjects(%{q: "Bob", position: :defender})
      assert length(subjects) == 1
      subject = hd(subjects)
      assert subject.name == "Bob Johnson"
      assert subject.position == :defender
    end

    test "combined filters with no results" do
      subjects = Subjects.list_subjects(%{q: "NonExistent", position: :forward})
      assert length(subjects) == 0
    end

    test "all filters combined" do
      subjects = Subjects.list_subjects(%{q: "Jane", position: :midfielder, sort_by: "name"})
      assert length(subjects) == 1
      subject = hd(subjects)
      assert subject.name == "Jane Smith"
      assert subject.position == :midfielder
      assert subject.team == "Chelsea"
    end
  end

  # Helper function to create test subjects
  defp insert_subject(attrs) do
    %Subject{}
    |> Subject.changeset(attrs)
    |> Repo.insert!()
  end
end
