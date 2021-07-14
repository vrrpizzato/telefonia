defmodule Contas do

  def imprimir(mes, ano, numero, plano) do
    assinante =  Assinante.buscar_assinante(numero)

    chamadas_mes = buscar_elementos_mes(assinante.chamadas, mes, ano)

    cond do
      plano == :prepago ->
        recargas_mes = buscar_elementos_mes(assinante.plano.recargas, mes, ano)
        plano = %Prepago{assinante.plano | recargas: recargas_mes}
        %Assinante{assinante | chamadas: chamadas_mes, plano: plano}

      plano == :pospago ->
        %Assinante{assinante | chamadas: chamadas_mes}

    end

  end

  defp buscar_elementos_mes(elementos, mes, ano) do
    elementos
    |> Enum.filter(&(&1.data.year == ano && &1.data.month == mes))
  end

end
