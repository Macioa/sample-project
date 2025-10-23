defmodule SubjectManagerWeb.AdminSubjectLive.Form do
  use SubjectManagerWeb, :live_view

  alias SubjectManager.Subjects
  alias SubjectManager.Subjects.Subject

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(page_title: "Admin - Subject Form")
      |> assign(subject: %Subject{})
      |> allow_upload(:image, accept: ~w(.jpg .jpeg .png .gif), max_entries: 1, max_file_size: 1_000_000_000)

    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _url, socket) do
    subject = Subjects.get_subject!(id)
    form = to_form(Subject.changeset(subject, %{}))

    socket =
      socket
      |> assign(subject: subject)
      |> assign(form: form)
      |> allow_upload(:image, accept: ~w(.jpg .jpeg .png .gif), max_entries: 1, max_file_size: 1_000_000_000)

    {:noreply, socket}
  end

  def handle_params(_params, _url, socket) do
    form = to_form(Subject.changeset(%Subject{}, %{}))

    socket =
      socket
      |> assign(subject: %Subject{})
      |> assign(form: form)
      |> allow_upload(:image, accept: ~w(.jpg .jpeg .png .gif), max_entries: 1, max_file_size: 1_000_000_000)

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

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :image, ref)}
  end

  def handle_event("progress", %{"ref" => _ref, "progress" => _progress}, socket) do
    {:noreply, socket}
  end

  def handle_event("upload", %{"upload" => %{"ref" => ref}}, socket) do
    {:noreply, socket}
  end

  defp save_subject(socket, %Subject{} = subject, subject_params) do
    uploaded_files = consume_uploaded_entries(socket, :image, fn %{path: path}, entry ->
      filename = "#{System.unique_integer([:positive])}_#{entry.client_name}"
      dest = Path.join([Application.app_dir(:subject_manager, "priv/static/images"), filename])

      File.mkdir_p!(Path.dirname(dest))
      File.cp!(path, dest)

      {:ok, "/images/#{filename}"}
    end)

    image_path = case uploaded_files do
      [image_path] -> image_path
      [] -> subject_params["image_path"] || subject.image_path || "/images/placeholder.jpg"
    end

    updated_params = Map.put(subject_params, "image_path", image_path)

    case subject.id do
      nil ->
        case Subjects.create_subject(updated_params) do
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
        case Subjects.update_subject(subject, updated_params) do
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

      <.simple_form for={@form} phx-change="validate" phx-submit="save" multipart={true}>
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

        <div class="space-y-2">
          <label class="block text-sm font-medium text-gray-700">Image</label>

          <div class="mt-1 flex justify-center px-6 pt-5 pb-6 border-2 border-gray-300 border-dashed rounded-md hover:border-gray-400 transition-colors" phx-drop-target={@uploads.image.ref}>
            <div class="space-y-1 text-center">
              <svg class="mx-auto h-12 w-12 text-gray-400" stroke="currentColor" fill="none" viewBox="0 0 48 48">
                <path d="M28 8H12a4 4 0 00-4 4v20m32-12v8m0 0v8a4 4 0 01-4 4H12a4 4 0 01-4-4v-4m32-4l-3.172-3.172a4 4 0 00-5.656 0L28 28M8 32l9.172-9.172a4 4 0 015.656 0L28 28m0 0l4 4m4-24h8m-4-4v8m-12 4h.02" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" />
              </svg>
              <div class="flex text-sm text-gray-600">
                <span class="relative cursor-pointer bg-white rounded-md font-medium text-sky-600 hover:text-sky-500 focus-within:outline-none focus-within:ring-2 focus-within:ring-offset-2 focus-within:ring-sky-500">
                  Upload a file
                  <.live_file_input upload={@uploads.image} class="absolute inset-0 w-full h-full opacity-0 cursor-pointer" />
                </span>
                <p class="pl-1">or drag and drop</p>
              </div>
              <p class="text-xs text-gray-500">PNG, JPG, GIF</p>
            </div>
          </div>

          <div :for={entry <- @uploads.image.entries} class="flex items-center space-x-2 p-2 bg-gray-50 rounded">
            <div class="flex-1 min-w-0">
              <p class="text-sm font-medium text-gray-900 truncate">{entry.client_name}</p>
              <p class="text-sm text-gray-500">{entry.progress}%</p>
            </div>
            <button
              type="button"
              phx-click="cancel-upload"
              phx-value-ref={entry.ref}
              class="text-red-600 hover:text-red-800 text-sm"
            >
              Remove
            </button>
          </div>

          <div :if={@subject.image_path && @subject.image_path != "/images/placeholder.jpg"} class="mt-2">
            <p class="text-sm text-gray-600">Current image:</p>
            <img src={@subject.image_path} alt="Current image" class="h-20 w-20 object-cover rounded" />
          </div>
        </div>

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
