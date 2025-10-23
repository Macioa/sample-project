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

  test "can create a new subject", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/admin/subjects/new")

    # Fill out the form
    view
    |> form("form", subject: %{
      name: "New Player",
      team: "New Team",
      position: "midfielder",
      bio: "A new player for testing"
    })
    |> render_submit()

    # Should redirect to admin index
    assert_redirect(view, ~p"/admin/subjects")

    # Verify the subject was created
    subject = Subjects.list_subjects() |> Enum.find(&(&1.name == "New Player"))
    assert subject
    assert subject.team == "New Team"
    assert subject.position == :midfielder
    assert subject.bio == "A new player for testing"
  end

  test "can edit an existing subject", %{conn: conn} do
    {:ok, subject} = Subjects.create_subject(%{
      name: "Original Player",
      team: "Original Team",
      position: :forward,
      bio: "Original bio",
      image_path: "/images/original.jpg"
    })

    {:ok, view, _html} = live(conn, ~p"/admin/subjects/#{subject.id}/edit")

    # Update the form
    view
    |> form("form", subject: %{
      name: "Updated Player",
      team: "Updated Team",
      position: "defender",
      bio: "Updated bio"
    })
    |> render_submit()

    # Should redirect to admin index
    assert_redirect(view, ~p"/admin/subjects")

    # Verify the subject was updated
    updated_subject = Subjects.get_subject!(subject.id)
    assert updated_subject.name == "Updated Player"
    assert updated_subject.team == "Updated Team"
    assert updated_subject.position == :defender
    assert updated_subject.bio == "Updated bio"
  end

  test "can delete a subject", %{conn: conn} do
    {:ok, subject} = Subjects.create_subject(%{
      name: "Player To Delete",
      team: "Team To Delete",
      position: :goalkeeper,
      bio: "This player will be deleted",
      image_path: "/images/delete.jpg"
    })

    {:ok, view, _html} = live(conn, ~p"/admin/subjects")

    # Verify subject exists
    assert has_element?(view, "div", subject.name)

    # Delete the subject
    view
    |> element("button[phx-click=\"delete\"][phx-value-id=\"#{subject.id}\"]")
    |> render_click()

    # Should show success message
    assert has_element?(view, "[role=\"alert\"]", "Subject deleted successfully")

    # Verify subject was deleted
    assert_raise Ecto.NoResultsError, fn ->
      Subjects.get_subject!(subject.id)
    end
  end

  test "shows validation errors for invalid subject data", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/admin/subjects/new")

    # Submit form with invalid data (missing required fields)
    view
    |> form("form", subject: %{
      name: "",
      team: "",
      position: "forward",  # Use valid position to avoid select validation error
      bio: ""
    })
    |> render_submit()

    # Should stay on the same page and show validation errors
    assert has_element?(view, "h1", "Add New Subject")
    assert has_element?(view, "[role=\"alert\"]")
  end

  test "form validation works in real-time", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/admin/subjects/new")

    # Clear the name field to trigger validation
    view
    |> form("form", subject: %{name: ""})
    |> render_change()

    # Should show validation error
    assert has_element?(view, "[role=\"alert\"]")
  end

  test "can navigate between admin pages", %{conn: conn} do
    {:ok, subject} = Subjects.create_subject(%{
      name: "Navigation Test Player",
      team: "Navigation Team",
      position: :winger,
      bio: "Testing navigation",
      image_path: "/images/nav.jpg"
    })

    # Test navigation to new subject form
    {:ok, view, _html} = live(conn, ~p"/admin/subjects/new")
    assert has_element?(view, "h1", "Add New Subject")

    # Test navigation to edit form
    {:ok, view, _html} = live(conn, ~p"/admin/subjects/#{subject.id}/edit")
    assert has_element?(view, "h1", "Edit Subject")

    # Test navigation back to admin index
    {:ok, view, _html} = live(conn, ~p"/admin/subjects")
    assert has_element?(view, "h1", "Manage Subjects")
    assert has_element?(view, "div", subject.name)
  end

  test "handles file upload in subject creation", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/admin/subjects/new")

    # Simulate file upload (this would normally be handled by the browser)
    # For testing purposes, we'll just test the form submission without file
    view
    |> form("form", subject: %{
      name: "Player With Image",
      team: "Image Team",
      position: "forward",
      bio: "Player with image upload"
    })
    |> render_submit()

    # Should redirect to admin index
    assert_redirect(view, ~p"/admin/subjects")

    # Verify the subject was created with placeholder image
    subject = Subjects.list_subjects() |> Enum.find(&(&1.name == "Player With Image"))
    assert subject
    assert subject.image_path == "/images/placeholder.jpg"
  end
end
