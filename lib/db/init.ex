defmodule ExGithubCleaner.Db do
  @moduledoc """
  TODO: Add a documentation for this module.
  """

  require Logger

  @default_migrate_file "migrate.sql"

  def default_migrate_file, do: @default_migrate_file

  @default_db_file "data.sqlite3"

  def default_db_file, do: @default_db_file

  @doc """
  TODO: Add a documentation for this function.
  """
  def filter_sql(sql_str) do
    sql_str
    |> String.replace(~r/--.*\n|\/\*[^\\]*\*\/|\t|^\s*|\s*$/, "")
    |> String.replace(~r/\n|  +/, " ")
    |> String.split(";")
    |> Enum.filter(&(String.length(&1) > 0))
    |> Enum.map(&(&1 <> ";"))
  end

  @doc """
  TODO: Add a documentation for this function.
  """
  def migrate(db_file, migrate_file) do
    case Exqlite.Basic.open(db_file) do
      {:ok, conn} ->
        "#{inspect(self())} Successfuly connected to the #{db_file} database file."
        |> Logger.debug()

        open_the_migration_file_to_continue(migrate_file, conn)

      {:error, reason} ->
        "#{inspect(self())} Couldn't open the #{db_file} database: #{reason}"
        |> Logger.error()

        {:error, reason}
    end
  end

  def migrate(), do: migrate(@default_db_file, @default_migrate_file)

  defp open_the_migration_file_to_continue(migrate_file, conn) do
    case File.read(migrate_file) do
      {:ok, sql_content} ->
        "#{inspect(self())} Successfuly found the #{migrate_file} migration file."
        |> Logger.debug()

        filter_sql(sql_content)
        |> build_final_result_list(conn)

      {:error, reason} ->
        "#{inspect(self())} Couldn't open the #{migrate_file} migration file: #{reason}"
        |> Logger.error()

        {:error, reason}
    end
  end

  defp build_final_result_list(sql_content, conn) do
    # This returns :ok because to the execution came here, it should already
    # oppened the migration file and connect to the database file Successfuly.
    {
      :ok,
      Enum.map(sql_content, &execution_evaluation_mapper(&1, conn))
    }
  end

  defp execution_evaluation_mapper(query, conn) do
    case Exqlite.Basic.exec(conn, query) do
      {:ok, _, _, _} ->
        "#{inspect(self())} Executed #{query} with success!"
        |> Logger.debug()

        {:ok, "commited"}

      {:error, %Exqlite.Error{message: reason}, _} ->
        "#{inspect(self())} Unexpected error with #{query}: #{reason}"
        |> Logger.error()

        {:error, reason}
    end
  end
end
