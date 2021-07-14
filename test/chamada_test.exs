defmodule ChamadaTest do
  use ExUnit.Case

  test "cobertura da estrutura" do
    assert %Chamada{data: DateTime.utc_now(), duracao: 10}. duracao == 10
  end
end
