defmodule ModelToCrdtConvertorTest do
  use Ghuguti.Case
  import Map
  alias Convertor.ModelToCrdt
  alias Riak.CRDT.Map
  
  test "should be able to convert a model into crdt" do
     model = BasicMap.new
     model_map = from_struct(model)

      ModelToCrdt.to_crdt(model)
      |> Riak.update("maps", "bucketmap", model.name)

    map = Riak.find("maps", "bucketmap", model.name) |> Map.value
    map_keys = :orddict.fetch_keys(map)

    assert {"is_interested", :flag} in map_keys
    assert {"name", :register} in map_keys
    assert {"age", :counter} in map_keys
    assert :orddict.size(map) == 3

    data = :orddict.to_list(map)
    assert {{"name", :register}, "subaru"} in data
    assert {{"age", :counter}, 30} in data
    assert {{"is_interested", :flag}, true} in data
 end

  test "should convert model with list to CRDT with Set" do
    key = Ghuguti.Helper.random_key
     model = BasicMapWithSet.new

      ModelToCrdt.to_crdt(model)
      |> Riak.update("maps", "bucketmap", key)

    map = Riak.find("maps", "bucketmap", key) |> Map.value

    map_keys = :orddict.fetch_keys(map)

    assert {"is_interested", :flag} in map_keys
    assert {"name", :register} in map_keys
    assert {"age", :counter} in map_keys
    assert {"interests", :set} in map_keys
    assert :orddict.size(map) == 4

    data = :orddict.to_list(map)
    assert {{"name", :register}, model.name} in data
    assert {{"age", :counter}, model.age} in data
    assert {{"is_interested", :flag}, false} in data
    assert {{"is_interested", :flag}, false} in data

    set = :orddict.fetch({"interests", :set}, map)
    assert "shopping" in set
    assert "watching movies" in set
 end

  test "should convert model with nested struct to crdt with nested map" do
    model = MapWithNestedMap.new("mustang_1", BasicMap.new)

      ModelToCrdt.to_crdt(model)
      |> Riak.update("maps", "bucketmap", model.name)

    map = Riak.find("maps", "bucketmap", model.name) |> Map.value
    map_keys = :orddict.fetch_keys(map)

    assert {"name", :register} in map_keys
    assert {"nested_struct", :map} in map_keys
    assert :orddict.size(map) == 2

    data = :orddict.to_list(map)
    assert {{"name", :register}, model.name} in data

    nested_map = :orddict.fetch({"nested_struct", :map}, map)
    
    assert :orddict.fetch({"name", :register}, nested_map) == "subaru"
    assert :orddict.fetch({"age", :counter}, nested_map) == 30
    assert :orddict.fetch({"is_interested", :flag}, nested_map) == true
  end

  test "should convert model with doubly nested struct to crdt with doubly nested map" do
    key = Ghuguti.Helper.random_key
    first_map = MapWithNestedMap.new("mustang_2", BasicMap.new)
    model = DoublyMapWithNestedMap.new("mustang_daddy", first_map)

      ModelToCrdt.to_crdt(model)
      |> Riak.update("maps", "bucketmap", key)

    map = Riak.find("maps", "bucketmap", key) |> Map.value
    map_keys = :orddict.fetch_keys(map)
    assert {"name", :register} in map_keys
    assert {"nested_struct", :map} in map_keys
    assert :orddict.size(map) == 2

    data = :orddict.to_list(map)
    assert {{"name", :register}, "mustang_daddy"} in data

    nested_map = :orddict.fetch({"nested_struct", :map}, map)
    
    assert :orddict.fetch({"name", :register}, nested_map) == "mustang_2"
    
    doubly_nested_map = :orddict.fetch({"nested_struct", :map}, nested_map)
    
    assert :orddict.fetch({"name", :register}, doubly_nested_map) == "subaru"
    assert :orddict.fetch({"age", :counter}, doubly_nested_map) == 30
    assert :orddict.fetch({"is_interested", :flag}, doubly_nested_map) == true
  end

  test "should convert model with int to crdt with counter" do
    key = Ghuguti.Helper.random_key
     model = MapWithCounter.new
     model 
     |> ModelToCrdt.to_crdt
     |> Riak.update("maps","bucketmap", key)

    map = Riak.find("maps", "bucketmap", key) |> Map.value
    IO.inspect map
    map_keys = :orddict.fetch_keys(map)
    assert {"name", :register} in map_keys
    assert {"age", :counter} in map_keys
    assert :orddict.size(map) == 2

     assert :orddict.fetch({"name", :register}, map) == model.name
    assert :orddict.fetch({"age", :counter}, map) == 23
  end


defp given_that_user_already_exists(user_id) do
      BasicMap.new(user_id)
      |> ModelToCrdt.to_crdt
      |> Riak.update("maps", "bucketmap", user_id)
end

end

defmodule BasicMap do
  defstruct name: "subaru", age: 30, is_interested: true

  def new do
    %BasicMap{}
  end

  def new(name) do
    %BasicMap{name: name} 
  end
end

defmodule BasicMapWithSet do
  defstruct [name: "rin_osaka", age: 23, is_interested: false, interests: ["shopping", "watching movies"]]

  def new do
    %BasicMapWithSet{} 
  end
end

defmodule BasicMapWithCounter do
  defstruct name: "rin_osaka_counter", age: 23

  def new do
    %BasicMapWithCounter{}
  end
end

defmodule MapWithCounter do
  defstruct name: "rin_osaka_counter", age: 23

  def new do
    %BasicMapWithCounter{}
  end
end

defmodule MapWithNestedMap do
  defstruct name: "rin_osaka", nested_struct: nil

  def new(name, nested_struct) do
    %MapWithNestedMap{name: name, nested_struct: nested_struct}
  end
end

defmodule DoublyMapWithNestedMap do
  defstruct name: nil, nested_struct: nil

  def new(name, nested_struct) do
    %DoublyMapWithNestedMap{name: name, nested_struct: nested_struct}
  end
end


