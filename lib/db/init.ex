defmodule ExGithubCleaner.Db do
  @moduledoc """
  TODO: Add a documentation for this module.
  """

  require Logger

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

  @default_migrate_file "migrate.sql"

  def default_migrate_file, do: @default_migrate_file

  @default_db_file "data.sqlite3"

  def default_db_file, do: @default_db_file

  @doc """
  TODO: Add a documentation for this function.
  """
  def migrate(db_file, migrate_file) do
    case Exqlite.Basic.open(db_file) do
      {:ok, conn} ->
        "#{inspect(self())} Successfuly connected to the #{db_file} database file."
        |> Logger.debug()

        case File.read(migrate_file) do
          {:ok, sql_content} ->
            "#{inspect(self())} Successfuly found the #{migrate_file} migration file."
            |> Logger.debug()

            {
              :ok,
              filter_sql(sql_content)
              |> Enum.map(fn query ->
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
              end)
            }

          {:error, reason} ->
            "#{inspect(self())} Couldn't open the #{migrate_file} migration file: #{reason}"
            |> Logger.error()

            {:error, reason}
        end

      {:error, reason} ->
        "#{inspect(self())} Couldn't open the #{db_file} database: #{reason}"
        |> Logger.error()

        {:error, reason}
    end
  end

  def migrate(), do: migrate(@default_db_file, @default_migrate_file)
end
