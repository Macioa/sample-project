defmodule SubjectManagerWeb.AdminSubjectLiveTest do
  use SubjectManagerWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  alias SubjectManager.Subjects

  test "admin index page loads and shows subjects", %{conn: conn} do
    # Create a test subject
    {:ok, subject} = Subjects.create_subject(%{
      name: "Test Player",
      team: "Test Team",
      position: :forward,
      bio: "A test player for testing purposes",
      image_path: "/images/test.jpg"
    })

    {:ok, view, _html} = live(conn, ~p"/admin/subjects")

    assert has_element?(view, "h1", "Manage Subjects")
    assert has_element?(view, "a", "Add New Subject")
    assert has_element?(view, "div", subject.name)
    assert has_element?(view, "div", subject.team)
  end

  test "admin form page loads for new subject", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/admin/subjects/new")

    assert has_element?(view, "h1", "Add New Subject")
    assert has_element?(view, "form")
    assert has_element?(view, "input[name=\"subject[name]\"]")
    assert has_element?(view, "input[name=\"subject[team]\"]")
    assert has_element?(view, "select[name=\"subject[position]\"]")
    assert has_element?(view, "textarea[name=\"subject[bio]\"]")
    assert has_element?(view, "input[type=\"file\"]")
  end

  test "admin form page loads for editing existing subject", %{conn: conn} do
    {:ok, subject} = Subjects.create_subject(%{
      name: "Test Player",
      team: "Test Team",
      position: :forward,
      bio: "A test player for testing purposes",
      image_path: "/images/test.jpg"
    })

    {:ok, view, _html} = live(conn, ~p"/admin/subjects/#{subject.id}/edit")

    assert has_element?(view, "h1", "Edit Subject")
    assert has_element?(view, "form")
    assert has_element?(view, "input[name=\"subject[name]\"][value=\"Test Player\"]")
    assert has_element?(view, "input[name=\"subject[team]\"][value=\"Test Team\"]")
  end
end
