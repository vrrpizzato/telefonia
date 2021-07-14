defmodule Prepago do
  defstruct creditos: 0, recargas: []

  @preco_minuto 1.45

  def fazer_chamada(numero, data, duracao) do
    assinante =  Assinante.buscar_assinante(numero, :prepago)
    custo = @preco_minuto * duracao

    cond  do
      custo <= assinante.plano.creditos ->
        plano = assinante.plano
        plano = %__MODULE__{plano | creditos: plano.creditos - custo}

        %Assinante{assinante | plano: plano}
        |> Chamada.registrar(data, duracao)

        {:ok, "Custo da chamada igual à #{custo}. Seu saldo é igual à #{plano.creditos}"}
      true ->
        {:error, "Créditos insuficiente, faça uma recarga"}
    end
  end

  def imprimir_conta(mes, ano, numero) do
    Contas. imprimir(mes, ano, numero, :prepago)
  end

end
