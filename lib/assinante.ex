defmodule Assinante do
  @moduledoc """
    Modulo de assinante para cadastro de tipos de assinantes como `prepago` e `pospago`
  """

  defstruct nome: nil, numero: nil, cpf: nil, plano: nil, chamadas: []

  @assinantes %{:prepago => "pre.txt", :pospago => "pos.txt"}

  @doc """
    Função de cadastramento de assinante `prepago` ou `pospago`

    ## Parametros da função

      - nome: nome do assinante
      - numero: número único, e, caso já existir, retorna um erro
      - cpf: cpf do assinante
      - plano: opcional, caso não seja informado, é cadastrado como um assinante `prepago`

    ## Exemplo

        iex > Assinante.cadastrar("Romano", "123", "456")
        {:ok, "Assinante Romano cadastrado com sucesso!"}

  """

  def cadastrar(nome, numero, cpf, :prepago), do: cadastrar(nome, numero, cpf, %Prepago{})
  def cadastrar(nome, numero, cpf, :pospago), do: cadastrar(nome, numero, cpf, %Pospago{})
  def cadastrar(nome, numero, cpf, plano) do
    case buscar_assinante(numero) do
      nil ->
        assinante = %__MODULE__{nome: nome, numero: numero, cpf: cpf, plano: plano}
        (read(retorna_plano(assinante)) ++ [assinante])
        |> :erlang.term_to_binary()
        |> write(retorna_plano(assinante))
        {:ok, "Assinante #{nome} cadastrado com sucesso!"}
      _assinante ->
        {:error, "Assinante com este número já cadastrado!"}
    end
  end

  def atualizar(numero, assinante) do
    {assinante_antigo, nova_lista} = remover(numero)

    case assinante.plano.__struct__ == assinante_antigo.plano.__struct__ do
      true ->
        (nova_lista ++ [assinante])
        |> :erlang.term_to_binary()
        |> write(retorna_plano(assinante))
      false ->
        {:error, "Assinante não pore alterar seu plano"}
    end
  end

  def deletar(numero) do
    {assinante, nova_lista} = remover(numero)

    nova_lista
    |> :erlang.term_to_binary()
    |> write(assinante.plano)
    {:ok, "Assinante #{assinante.nome} removido!"}
  end

  def remover(numero) do
    assinante = buscar_assinante(numero)

    nova_lista = read(retorna_plano(assinante))
    |> List.delete(assinante)
    {assinante, nova_lista}
  end

  defp retorna_plano(assinante) do
    case assinante.plano.__struct__ == Prepago do
      true -> :prepago
      false -> :pospago
    end
  end

  def buscar_assinante(numero, key \\ :all), do: buscar(numero, key)
  defp buscar(numero, :all), do: filtro(assinantes(), numero)
  defp buscar(numero, :pospago), do: filtro(assinantes_pospago(), numero)
  defp buscar(numero, :prepago), do: filtro(assinantes_prepago(), numero)
  defp filtro(lista, numero), do: Enum.find(lista, &(&1.numero == numero))

  def assinantes(), do: read(:prepago) ++ read(:pospago)
  def assinantes_pospago(), do: read(:pospago)
  def assinantes_prepago(), do: read(:prepago)

  defp write(lista_assinantes, plano) do
    File.write!(@assinantes[plano], lista_assinantes)
  end

  def read(plano) do
    case File.read(@assinantes[plano]) do
      {:ok, assinantes} ->
        assinantes
        |> :erlang.binary_to_term()
      {:error, :enoent} ->
        {:error, "Arquivo inválido!"}
    end
  end

end
