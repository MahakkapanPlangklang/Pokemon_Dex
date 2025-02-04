import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'pokemon_detail.dart';
import 'package:google_fonts/google_fonts.dart';

class PokemonListScreen extends StatefulWidget {
  @override
  _PokemonListScreenState createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen> {
  List<dynamic> pokemonList = [];
  String nextUrl = "https://pokeapi.co/api/v2/pokemon?limit=20";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchPokemon();
  }

  Future<void> fetchPokemon() async {
    if (isLoading || nextUrl.isEmpty) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(nextUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          pokemonList.addAll(data['results']);
          nextUrl = data['next'] ?? "";
        });
      } else {
        throw Exception("Failed to load Pokémon data");
      }
    } catch (e) {
      print("Error fetching Pokémon list: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pokémon Dex", style: GoogleFonts.poppins()),
        backgroundColor: Colors.redAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.redAccent, Colors.orangeAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView.builder(
          itemCount: pokemonList.length + 1,
          itemBuilder: (context, index) {
            if (index == pokemonList.length) {
              return nextUrl.isEmpty
                  ? SizedBox.shrink()
                  : Center(child: CircularProgressIndicator());
            }
            var pokemon = pokemonList[index];
            int pokemonId = index + 1;

            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: EdgeInsets.all(8),
              child: ListTile(
                leading: Image.network(
                  "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$pokemonId.png",
                  width: 80,
                  height: 80,
                  errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported),
                ),
                title: Text(
                  pokemon['name'].toUpperCase(),
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PokemonDetailScreen(pokemonId: pokemonId),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchPokemon,
        child: isLoading ? CircularProgressIndicator(color: Colors.white) : Icon(Icons.add),
        backgroundColor: Colors.redAccent,
      ),
    );
  }
}
