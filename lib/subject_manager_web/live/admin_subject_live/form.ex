defmodule SubjectManagerWeb.AdminSubjectLive.Form do
  use SubjectManagerWeb, :live_view

  alias SubjectManager.Subjects
  alias SubjectManager.Subjects.Subject

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(page_title: "Admin - Subject Form")
      |> assign(subject: %Subject{})

    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _url, socket) do
    subject = Subjects.get_subject!(id)
    form = to_form(Subject.changeset(subject, %{}))

    socket =
      socket
      |> assign(subject: subject)
      |> assign(form: form)

    {:noreply, socket}
  end

  def handle_params(_params, _url, socket) do
    form = to_form(Subject.changeset(%Subject{}, %{}))

    socket =
      socket
      |> assign(subject: %Subject{})
      |> assign(form: form)

    {:noreply, socket}
  end

  def handle_event("validate", %{"subject" => subject_params}, socket) do
    changeset =
      socket.assigns.subject
      |> Subject.changeset(subject_params)
      |> Map.put(:action, :validate)

    form = to_form(changeset)

    {:noreply, assign(socket, form: form)}
  end

  def handle_event("save", %{"subject" => subject_params}, socket) do
    save_subject(socket, socket.assigns.subject, subject_params)
  end

  defp save_subject(socket, %Subject{} = subject, subject_params) do
    case subject.id do
      nil ->
        case Subjects.create_subject(subject_params) do
          {:ok, _subject} ->
            socket =
              socket
              |> put_flash(:info, "Subject created successfully")
              |> push_navigate(to: ~p"/admin/subjects")

            {:noreply, socket}

          {:error, %Ecto.Changeset{} = changeset} ->
            {:noreply, assign(socket, form: to_form(changeset))}
        end

      _id ->
        case Subjects.update_subject(subject, subject_params) do
          {:ok, _subject} ->
            socket =
              socket
              |> put_flash(:info, "Subject updated successfully")
              |> push_navigate(to: ~p"/admin/subjects")

            {:noreply, socket}

          {:error, %Ecto.Changeset{} = changeset} ->
            {:noreply, assign(socket, form: to_form(changeset))}
        end
    end
  end

  def render(assigns) do
    ~H"""
    <div id="subject-form">
      <div class="mb-6">
        <.link navigate={~p"/admin/subjects"} class="inline-flex items-center gap-2 text-sky-600 hover:text-sky-800 transition ease-in-out duration-150">
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"></path>
          </svg>
          Back to Admin
        </.link>
      </div>

      <h1 class="text-2xl font-bold text-gray-900 mb-6">
        <%= if @subject.id, do: "Edit Subject", else: "Add New Subject" %>
      </h1>

      <.simple_form for={@form} phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:team]} type="text" label="Team" />
        <.input
          field={@form[:position]}
          type="select"
          label="Position"
          options={[
            Forward: :forward,
            Midfielder: :midfielder,
            Winger: :winger,
            Defender: :defender,
            Goalkeeper: :goalkeeper
          ]}
        />
        <.input field={@form[:bio]} type="textarea" label="Bio" />
        <.input field={@form[:image_path]} type="text" label="Image Path" />

        <:actions>
          <.button type="submit" phx-disable-with="Saving...">
            <%= if @subject.id, do: "Update Subject", else: "Create Subject" %>
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end
end
