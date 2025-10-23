defmodule SubjectManagerWeb.SubjectLive.Show do
  use SubjectManagerWeb, :live_view

  alias SubjectManager.Subjects
  import SubjectManagerWeb.CustomComponents

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _url, socket) do
    subject = Subjects.get_subject!(id)

    socket =
      socket
      |> assign(page_title: subject.name)
      |> assign(subject: subject)

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="subject-show">
      <div class="mb-6">
        <.link navigate={~p"/subjects"} class="inline-flex items-center gap-2 text-sky-600 hover:text-sky-800 transition ease-in-out duration-150">
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"></path>
          </svg>
          Back to Subjects
        </.link>
      </div>

      <div class="subject">
        <img src={@subject.image_path} alt={@subject.name} />
        <section>
          <header>
            <h2>{@subject.name}</h2>
            <h3>{@subject.team}</h3>
            <.badge status={@subject.position} />
          </header>
          <div class="description">
            {@subject.bio}
          </div>
        </section>
      </div>
    </div>
    """
  end
end
