defmodule PospagoTest do
  use ExUnit.Case

  setup do
    File.write("pre.txt", :erlang.term_to_binary([]))
    File.write("pos.txt", :erlang.term_to_binary([]))

    on_exit(fn ->
      File.rm("pre.txt")
      File.rm("pos.txt")
    end)
  end

  test "fazer ligação" do
    Assinante.cadastrar("Victor", "456", "123", :pospago)

    assert Pospago.fazer_chamada("456", DateTime.utc_now(), 5) ==
       {:ok, "Chamada efetuada com sucesso! Duração de 5 minutos"}

  end

  test "informar fatura da conta do mês" do
    Assinante.cadastrar("Victor", "123", "456", :pospago)

    data = DateTime.utc_now()

    Pospago.fazer_chamada("123", data, 3)
    Pospago.fazer_chamada("123", data, 3)
    Pospago.fazer_chamada("123", data, 3)
    Pospago.fazer_chamada("123", data, 3)

    assinante = Assinante.buscar_assinante("123", :pospago)
    assert Enum.count(assinante.chamadas) == 4

    assinante = Pospago.imprimir_conta(data.month, data.year, "123")
    assert Enum.count(assinante.chamadas) == 4
    assert assinante.plano.valor == 16.799999999999997

  end

end
