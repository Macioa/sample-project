defmodule SubjectManager.SubjectsTest do
  use SubjectManager.DataCase, async: true
  alias SubjectManager.Subjects
  alias SubjectManager.Subjects.Subject

  test "create_subject/1 with valid data creates a subject" do
    valid_attrs = %{
      name: "Test Player",
      team: "Test Team",
      position: :forward,
      bio: "A test player with enough characters",
      image_path: "/images/test.jpg"
    }

    assert {:ok, %Subject{} = subject} = Subjects.create_subject(valid_attrs)
    assert subject.name == "Test Player"
    assert subject.team == "Test Team"
    assert subject.position == :forward
    assert subject.bio == "A test player with enough characters"
    assert subject.image_path == "/images/test.jpg"
  end

  test "create_subject/1 with invalid data returns error changeset" do
    invalid_attrs = %{name: "", team: "", position: nil}
    assert {:error, %Ecto.Changeset{}} = Subjects.create_subject(invalid_attrs)
  end

  test "update_subject/2 with valid data updates the subject" do
    {:ok, subject} = Subjects.create_subject(%{
      name: "Original Name",
      team: "Original Team",
      position: :forward,
      bio: "Original bio with enough characters",
      image_path: "/images/original.jpg"
    })

    update_attrs = %{
      name: "Updated Name",
      team: "Updated Team",
      position: :midfielder,
      bio: "Updated bio"
    }

    assert {:ok, %Subject{} = updated_subject} = Subjects.update_subject(subject, update_attrs)
    assert updated_subject.name == "Updated Name"
    assert updated_subject.team == "Updated Team"
    assert updated_subject.position == :midfielder
    assert updated_subject.bio == "Updated bio"
  end

  test "update_subject/2 with invalid data returns error changeset" do
    {:ok, subject} = Subjects.create_subject(%{
      name: "Test Player",
      team: "Test Team",
      position: :forward,
      bio: "Test bio with enough characters",
      image_path: "/images/test.jpg"
    })

    invalid_attrs = %{name: "", team: ""}
    assert {:error, %Ecto.Changeset{}} = Subjects.update_subject(subject, invalid_attrs)
  end

  test "delete_subject/1 deletes the subject" do
    {:ok, subject} = Subjects.create_subject(%{
      name: "Player To Delete",
      team: "Team To Delete",
      position: :goalkeeper,
      bio: "This will be deleted with enough characters",
      image_path: "/images/delete.jpg"
    })

    assert {:ok, %Subject{}} = Subjects.delete_subject(subject)
    assert_raise Ecto.NoResultsError, fn -> Subjects.get_subject!(subject.id) end
  end

  test "get_subject!/1 returns the subject with given id" do
    {:ok, subject} = Subjects.create_subject(%{
      name: "Test Player",
      team: "Test Team",
      position: :defender,
      bio: "Test bio with enough characters",
      image_path: "/images/test.jpg"
    })

    assert Subjects.get_subject!(subject.id) == subject
  end

  test "list_subjects/0 returns all subjects" do
    {:ok, subject1} = Subjects.create_subject(%{
      name: "Player 1",
      team: "Team 1",
      position: :forward,
      bio: "Bio 1 with enough characters",
      image_path: "/images/1.jpg"
    })

    {:ok, subject2} = Subjects.create_subject(%{
      name: "Player 2",
      team: "Team 2",
      position: :midfielder,
      bio: "Bio 2 with enough characters",
      image_path: "/images/2.jpg"
    })

    subjects = Subjects.list_subjects()
    assert length(subjects) == 2
    assert subject1 in subjects
    assert subject2 in subjects
  end
end
