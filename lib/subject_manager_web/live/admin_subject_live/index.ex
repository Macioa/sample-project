defmodule SubjectManagerWeb.AdminSubjectLive.Index do
  use SubjectManagerWeb, :live_view

  alias SubjectManager.Subjects

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(page_title: "Admin - Subjects")
      |> assign(subjects: Subjects.list_subjects())
      |> assign(form: to_form(%{}))

    {:ok, socket}
  end

  def handle_params(params, _url, socket) do
    filter_params = %{
      q: params["q"],
      position: params["position"],
      sort_by: params["sort_by"]
    }

    subjects = Subjects.list_subjects(filter_params)
    form = to_form(Map.new(filter_params, fn {k, v} -> {to_string(k), v} end))

    socket =
      socket
      |> assign(subjects: subjects)
      |> assign(form: form)

    {:noreply, socket}
  end

  def handle_event("validate", params, socket) do
    filter_params = params
    |> Map.take(["q", "position", "sort_by"])
    |> Enum.reject(fn {_k, v} -> v == nil or v == "" end)
    |> Map.new()

    {:noreply, push_patch(socket, to: ~p"/admin/subjects?#{filter_params}")}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    subject = Subjects.get_subject!(id)
    {:ok, _} = Subjects.delete_subject(subject)

    socket =
      socket
      |> put_flash(:info, "Subject deleted successfully")
      |> assign(subjects: Subjects.list_subjects())

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="admin-index">
      <div class="flex justify-between items-center mb-6">
        <h1 class="text-2xl font-bold text-gray-900">Manage Subjects</h1>
        <.link navigate={~p"/admin/subjects/new"} class="button">
          Add New Subject
        </.link>
      </div>

      <div class="subject-index">
        <.filter_form form={@form} />
      </div>

      <div class="bg-white shadow overflow-hidden sm:rounded-md">
        <ul class="divide-y divide-gray-200">
          <li :for={subject <- @subjects} class="px-6 py-4">
            <div class="flex items-center justify-between">
              <div class="flex items-center">
                <img class="h-10 w-10 rounded-full" src={subject.image_path} alt={subject.name} />
                <div class="ml-4">
                  <div class="text-sm font-medium text-gray-900">{subject.name}</div>
                  <div class="text-sm text-gray-500">{subject.team} • {subject.position}</div>
                </div>
              </div>
              <div class="flex items-center space-x-2">
                <.link navigate={~p"/admin/subjects/#{subject.id}/edit"} class="text-sky-600 hover:text-sky-800">
                  Edit
                </.link>
                <button
                  phx-click="delete"
                  phx-value-id={subject.id}
                  phx-confirm="Are you sure you want to delete this subject?"
                  class="text-red-600 hover:text-red-800"
                >
                  Delete
                </button>
              </div>
            </div>
          </li>
        </ul>
      </div>
    </div>
    """
  end

  attr(:form, Phoenix.HTML.Form, required: true)

  def filter_form(assigns) do
    ~H"""
    <.form for={@form} id="filter-form" phx-change="validate">
      <.input field={@form[:q]} placeholder="Search..." autocomplete="off" />
      <.input
        type="select"
        field={@form[:position]}
        prompt="Position"
        options={[
          Forward: "forward",
          Midfielder: "midfielder",
          Winger: "winger",
          Defender: "defender",
          Goalkeeper: "goalkeeper"
        ]}
      />
      <.input
        type="select"
        field={@form[:sort_by]}
        prompt="Sort By"
        options={[
          Name: "name",
          Team: "team",
          Position: "position"
        ]}
      />

      <.link patch={~p"/admin/subjects"}>
        Reset
      </.link>
    </.form>
    """
  end
end
