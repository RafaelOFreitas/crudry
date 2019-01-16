defmodule ResolverFunctionsGenerator do
  @moduledoc false

  def generate_function(:get, name, context) do
    quote do
      def unquote(:"get_#{name}")(%{id: id}, _info) do
        apply(unquote(context), String.to_existing_atom("get_#{unquote(name)}"), [id])
        |> nil_to_error(fn record -> {:ok, record} end)
      end
    end
  end

  def generate_function(:list, name, context) do
    pluralized_name = Inflex.pluralize(name)

    quote do
      def unquote(:"list_#{pluralized_name}")(_args, _info) do
        {:ok, apply(unquote(context), String.to_existing_atom("list_#{unquote(pluralized_name)}"), [])}
      end
    end
  end

  def generate_function(:create, name, context) do
    quote do
      def unquote(:"create_#{name}")(%{params: params}, _info) do
        apply(unquote(context), String.to_existing_atom("create_#{unquote(name)}"), [params])
      end
    end
  end

  def generate_function(:update, name, context) do
    quote do
      def unquote(:"update_#{name}")(%{id: id, params: params}, _info) do
        apply(unquote(context), String.to_existing_atom("get_#{unquote(name)}"), [id])
        |> nil_to_error(fn record -> apply(unquote(context), String.to_existing_atom("update_#{unquote(name)}"), [record, params]) end)
      end
    end
  end

  def generate_function(:delete, name, context) do
    quote do
      def unquote(:"delete_#{name}")(%{id: id}, _info) do
        apply(unquote(context), String.to_existing_atom("get_#{unquote(name)}"), [id])
        |> nil_to_error(fn record -> apply(unquote(context), String.to_existing_atom("delete_#{unquote(name)}"), [record]) end)
      end
    end
  end

  def generate_function(:nil_to_error, name, _context) do
    quote do
      def unquote(:nil_to_error)(result, func) do
        case result do
          nil -> {:error, "#{Macro.camelize(unquote(name))} not found."}
          %{} = record -> func.(record)
        end
      end
    end
  end
end
