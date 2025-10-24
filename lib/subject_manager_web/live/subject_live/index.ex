defmodule SubjectManagerWeb.SubjectLive.Index do
  use SubjectManagerWeb, :live_view

  alias SubjectManager.Subjects
  import SubjectManagerWeb.CustomComponents

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(page_title: "Subjects")
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
    filter_params =
      params
      |> Map.take(["q", "position", "sort_by"])
      |> Enum.reject(fn {_k, v} -> v == nil or v == "" end)
      |> Map.new()

    {:noreply, push_patch(socket, to: ~p"/subjects?#{filter_params}")}
  end

  def render(assigns) do
    ~H"""
    <div class="subject-index">
      <.filter_form form={@form} />

      <div class="subjects" id="subjects">
        <div id="empty" class="no-results only:block hidden">
          No subjects found. Try changing your filters.
        </div>
        <.subject :for={subject <- @subjects} subject={subject} dom_id={"subject-#{subject.id}"} />
      </div>
    </div>
    """
  end

  attr(:subject, SubjectManager.Subjects.Subject, required: true)
  attr(:dom_id, :string, required: true)

  def subject(assigns) do
    ~H"""
    <.link navigate={~p"/subjects/#{@subject}"} id={@dom_id}>
      <div class="card">
        <img src={@subject.image_path} />
        <h2>{@subject.name}</h2>
        <div class="details">
          <div class="team">
            {@subject.team}
          </div>
          <.badge status={@subject.position} />
        </div>
      </div>
    </.link>
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

      <.link patch={~p"/subjects"}>
        Reset
      </.link>
    </.form>
    """
  end
end
