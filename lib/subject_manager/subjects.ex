defmodule SubjectManager.Subjects do
  alias SubjectManager.Subjects.Subject
  alias SubjectManager.Repo
  import Ecto.Query

  def list_subjects do
    Repo.all(Subject)
  end

  def list_subjects(params) do
    Subject
    |> filter_by_name(params[:q])
    |> filter_by_position(params[:position])
    |> sort_by_field(params[:sort_by])
    |> Repo.all()
  end

  def get_subject!(id), do: Repo.get!(Subject, id)

  defp filter_by_name(query, nil), do: query
  defp filter_by_name(query, ""), do: query
  defp filter_by_name(query, name) do
    where(query, [s], like(s.name, ^"%#{name}%"))
  end

  defp filter_by_position(query, nil), do: query
  defp filter_by_position(query, ""), do: query
  defp filter_by_position(query, position) do
    where(query, [s], s.position == ^position)
  end

  defp sort_by_field(query, nil), do: query
  defp sort_by_field(query, ""), do: query
  defp sort_by_field(query, "name"), do: order_by(query, [s], asc: s.name)
  defp sort_by_field(query, "team"), do: order_by(query, [s], asc: s.team)
  defp sort_by_field(query, "position"), do: order_by(query, [s], asc: s.position)
  defp sort_by_field(query, _), do: query
end
