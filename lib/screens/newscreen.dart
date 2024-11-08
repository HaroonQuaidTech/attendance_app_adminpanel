// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unused_field, prefer_final_fields

import 'package:flutter/material.dart';

class Newscreen extends StatefulWidget {
  const Newscreen({super.key});

  @override
  State<Newscreen> createState() => _NewscreenState();
}

class _NewscreenState extends State<Newscreen> {
  List  _stories=['Story1','story2','story3','story4','story5','story6','story7','story8'];
    List  _posts=['Post1','Post2','Post3','Post4'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 50,),
          Row(
            children: [
              Flexible(
                
                child: SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: _stories.length,
                    itemBuilder: (context, index) {
                      return Container(
                        
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(90)
                        ),
                        child: Center(child: Text(  _stories[index],)),
                      );
                    },
                  ),
                ),
              ),
              Container(
                        
                        margin: EdgeInsets.all(10),
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey
                        ),
                        child: Icon(Icons.add, size: 30),
                      )
            ],
          ),
          Expanded(
            child: ListView.builder
            (
              itemCount: _posts.length,
              
              itemBuilder: (context,index){
                return Container(
                          
                          margin: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                          height: 200,
                          width: 60,
                          decoration: BoxDecoration(
                            color: Colors.pink[100],
                            borderRadius: BorderRadius.circular(10)
                          ),
                          child: Center(child: Text(  _posts[index],)),
                        );
            
              }),
          )



        ],
      ),
    );
  }
}
