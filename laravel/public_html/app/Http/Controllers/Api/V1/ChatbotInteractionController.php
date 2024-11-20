<?php

namespace App\Http\Controllers\Api\V1;

use App\Models\census;
use App\Models\ChatbotInteraction;
use App\Http\Controllers\Controller;
use App\Http\Requests\StoreChatbotInteractionRequest;
use App\Http\Requests\UpdateChatbotInteractionRequest;
use App\Models\User;
use Illuminate\Http\Request;
use GuzzleHttp\Client;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
class ChatbotInteractionController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        //
    }

    /**
     * Show the form for creating a new resource.
     */
    public function create()
    {
        //
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(StoreChatbotInteractionRequest $request)
    {
        //
    }

    /**
     * Display the specified resource.
     */
    public function show(ChatbotInteraction $chatbotInteraction)
    {
        //
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(ChatbotInteraction $chatbotInteraction)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(UpdateChatbotInteractionRequest $request, ChatbotInteraction $chatbotInteraction)
    {
        //
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(ChatbotInteraction $chatbotInteraction)
    {
        //
    }

    
public function processMessage(Request $request)
{
    $this->validate($request, [
        'message' => 'required|string',
    ]);

    $message = $request->input('message');

    // Replace 'YOUR_ACCESS_TOKEN' with the actual Wit.ai access token
    $witAiAccessToken = 'XBPQPDRMD22SSBLAPNZAQTFXAIPXG24S';

    $httpClient = new Client();

    // Send user message to wit.ai for analysis
    $witResponse = $httpClient->get('https://api.wit.ai/message', [
        'query' => [
            'q' => $message,
        ],
        'headers' => [
            'Authorization' => 'Bearer ' . $witAiAccessToken,
        ],
    ]);

    $witData = json_decode($witResponse->getBody(), true);

    // Extract intent and entities from wit.ai response
    $intent = $witData['intents'][0]['name'] ?? null;
    $entities = $witData['entities'] ?? [];

    // Log intent and entities for debugging
    Log::info('Intent: ' . $intent);
    Log::info('Entities: ' . json_encode($entities));
    Log::info('Received Message: ' . $message);
    Log::info(json_encode($witData));

    // Handle intents based on wit.ai analysis
    if ($intent === 'greeting_intent') {
        // Greet the user and ask about their document request
        $greetResponses = [
            "Hello!, How may I help you regarding your document request?",
            "Greetings!, How can I assist you today?",
            "Hello! How can I assist you with your document request?",
            "Kamusta User!, Ano ang maililingkod ko ngayong araw?",
        ];
        $randomResponse = $greetResponses[array_rand($greetResponses)];
    
        $response = $randomResponse;
        return response()->json(['response' => $response]);
    } elseif ($intent === 'documentRequest_intent') {
        // Extract requested document type
        $requestedDocument = $entities['document_type'][0]['value'] ?? null;
    
        // Store the document type in the session for later use
        session(['document' => $requestedDocument]);
    
        // Send a special response to indicate the Flutter UI to show the full name input form
        $response = "What document are you requesting? You can click on the 'Request Documents' and state your reason why you're requesting a document before you can generate a QR code";
       // return response()->json(['response' => $response, 'action' => 'show_full_name_form']); , 'action' => 'generate_QR_code'
        return response()->json(['response' => $response]);
    } elseif ($intent === 'help'){

        $helpResponses = [
            "Sure! To request a document from our barangay, Click on the 'Request Documents' and type your reason why you're requesting a document and pick a document before generating a QR Code .",
            "To request a document, Click the 'Request Documents' and type your reason for getting such document then pick a document listed before hitting Generate QR Code.",
            "Need a document? No problem! Tell me the name of the document you're looking for, like 'Barangay Clearance' or 'Barangay ID'.",
            "Hello! Ready to use our system?, Please go to the Tutorial section and read more about the system.",
            "Kailangan mo ng dokumento galing sa aming barangay?, I-type mo lang ang dokumento na katulad ng 'Barangay Clearance' o 'Barangay ID'.",
            "You need help? No problem!, Just tell me the name of the document you're looking for, like a 'Certificate of Indigency' or 'Barangay Clearance'",
        ];

        // Randomly select a response from the list
        $randomResponse = $helpResponses[array_rand($helpResponses)];

        // Assign the selected response to $response
        $response = $randomResponse;
        return response()->json(['response' => $response]);

    } elseif ($intent === 'hotline') {
        $response = "This is the hotlines provided in our barangay.";
        return response()->json(['response' => $response, 'action' => 'show_hotline']);
    } elseif ($intent === 'other_intent') {
        
        $otherResponses = [
            "Sorry, I'm only designed as a help desk in the system,.",
            "My apologies, I'm only designed as a help desk in the system, if you have other concerns, please go to our Barangay Hall for more information.",
            "I'm sorry, the chatbot is only designed as a help desk in the system, You can go to our barangay if you have concerns.",
            //"Patawad, Dinesenyo ako para maghawak ng request ng mga dokumento sa ating barangay, Pwede ka naman pumunta sa aming barangay sa mga ganyang impormasyon",
        ]; 

        $randomResponse = $otherResponses[array_rand($otherResponses)];
        $response = $randomResponse;
        return response()->json(['response' => $response]);

        //if user intents are in Tagalog when asking about the system.
    } elseif ($intent === 'cost') {
        $otherResponses = [
            "Depende ito sa gusto mong kuhanin na document sa aming barangay, pero di lalagpas ng isang daang piso. ",
            "Yung babayaran ng nagrequest, ay naka-salalay sa kanyang gustong kuhanin na dokumento",
        ];

        $randomResponse = $otherResponses[array_rand($otherResponses)];
        $response = $randomResponse;
        return response()->json(['response' => $response]);
        
    } elseif ($intent === 'day') {
        $otherResponses = [
            "Depende parin sa dokumento na iyong kukuhanin, kapag ang dokumento ay naproseso na, makakatanggap ka ng kompirmasyon sa iyong email",
            "Makakatanggap ka ng confirmation kalakip nito ang araw kung kailan mo makukuha yung dokumento na iyong ni-request",
        ];

        $randomResponse = $otherResponses[array_rand($otherResponses)];
        $response = $randomResponse;
        return response()->json(['response' => $response]);
        
    } elseif ($intent === 'elderly') {
        $otherResponses = [
            "Kelangan pumunta ang nagrequest ng dokumento pero depende parin sa barangay, kung mayroon exemption sa mga senior citizen",
            "Kung sino nagrequest ng dokumento, ay dapat na magtungo sa barangay, sa araw ng pagkuha ng dokumento",
        ];

        $randomResponse = $otherResponses[array_rand($otherResponses)];
        $response = $randomResponse;
        return response()->json(['response' => $response]);
        
    } elseif ($intent === 'first_come') {
        $otherResponses = [
            "Mayroon tayong sinusunod na queue depende sa oras ng kanilang pagregister ng kanilang mga impormasyon",
            "Kung sino ang naunang ng request, sya din ang mauuna na makuha ito",
        ];

        $randomResponse = $otherResponses[array_rand($otherResponses)];
        $response = $randomResponse;
        return response()->json(['response' => $response]);
        
    } elseif ($intent === 'requirements') {
        $otherResponses = [
            "Kailangan mong dalhin ang inyon resibo o katunayan na maaari mo ng iclaim ang iyong mga nirequest, pati na ang iyong valid id na nagpapatunay na ikaw ang nagrequest",
            "Ang valid id at resibo ang kelangan mong dalhin para maclaim mo ang iyong mga nirequest sa barangay",
        ];

        $randomResponse = $otherResponses[array_rand($otherResponses)];
        $response = $randomResponse;
        return response()->json(['response' => $response]);
        
    } elseif ($intent === 'technique') {
        $otherResponses = [
            "Walang pwedeng ibang gawin kundi ang magregister sa aming system upang makapagrequest ka ng document na nais mong makuha",
            "Mapapabilis din ang pagkuha mo ng documents kung ikaw ay residente ng aming barangay",
        ];

        $randomResponse = $otherResponses[array_rand($otherResponses)];
        $response = $randomResponse;
        return response()->json(['response' => $response]);
        
    } elseif ($intent === 'time_frame') {
        $otherResponses = [
            "Makakatanggap ka ng confirmation sa iyong email, kalakip nito ang araw kung kailan mo makukuha yung dokumento na iyong ni-request",
           // "Mapapabilis din ang pagkuha mo ng documents kung ikaw ay residente ng aming barangay",
        ];

        $randomResponse = $otherResponses[array_rand($otherResponses)];
        $response = $randomResponse;
        return response()->json(['response' => $response]);
    } elseif ($intent === 'ask_direction_tagalog') {
        $otherResponses = [
            "The address of the barangay hall of Central Bicutan can be found at Ferrer Street, Taguig City, National Capital Region, 1631",
           // "Mapapabilis din ang pagkuha mo ng documents kung ikaw ay residente ng aming barangay",
        ];

        $randomResponse = $otherResponses[array_rand($otherResponses)];
        $response = $randomResponse;
        return response()->json(['response' => $response]);
        
    } elseif ($intent === 'about_tagalog') {
        $otherResponses = [
            "Itong system na ito ay dinesenyo para mag-handle ng document request gamit ng pag generate ng QR Code para sa barangay Central Bicutan",
            "Nilikha itong sistemang ito para mag-hawak ng mga document request gamit ang pag generate ng QR Code para sa barangay Central Bicutan",
        ];

        $randomResponse = $otherResponses[array_rand($otherResponses)];
        $response = $randomResponse;
        return response()->json(['response' => $response]);

    } elseif ($intent === 'about_tagalog_origin') {
        $otherResponses = [
            "Itong system na ito ay ginawa ng mga 4th year BSCS students para sa isang thesis sa Taguig City University, at dinesenyo ito para maghandle ng mga request ng mga dokumento para sa barangay Central Bicutan",
            "Ang sistemang ito ay ginawa para sa isang thesis ng isang groupo ng mga kolehiyong nagaaral ng Bachelor of Science in Computer Science sa Taguig City University",
        ];

        $randomResponse = $otherResponses[array_rand($otherResponses)];
        $response = $randomResponse;
        return response()->json(['response' => $response]);

    } elseif ($intent === 'about_tagalog_dev') {
        $otherResponses = [
            "Itong system na ito ay ginawa lamang ng isang groupo ng mga estuyanteng nag-aaral ng Computer Science sa Taguig City University sa loob ng isang semester gamit ang Flutter SDK at Laravel framework.",

            "Ang sistemang ito ay ginawa gamit Flutter SDK at Laravel framework para sa isang thesis ng isang groupo ng mga kolehiyong nagaaral ng Bachelor of Science in Computer Science sa Taguig City University",
           
        ];

        $randomResponse = $otherResponses[array_rand($otherResponses)];
        $response = $randomResponse;
        return response()->json(['response' => $response]);

    } elseif ($intent === 'about_tagalog_scope') {
        $otherResponses = [
            "Ang sakop lang ng sistemang ito ay nakapaloob lang ng barangay Central Bicutan, at kelangan ng browser at internet connection / mobile data para magamit ang sistema",
            "Sakop lang ng sistemang ito ay nakapaloob lang base sa census ng barangay Central Bicutan",
        ];

        $randomResponse = $otherResponses[array_rand($otherResponses)];
        $response = $randomResponse;
        return response()->json(['response' => $response]);
    } elseif ($intent === 'about_tagalog_benefit') {
        $otherResponses = [
            "Ang benefisyong makukuha dito sa aming sistema, na mas mapapadali at less hassle dahil di na sila pupunta sa barangay para mag request ng dokumento online",
        ];

        $randomResponse = $otherResponses[array_rand($otherResponses)];
        $response = $randomResponse;
        return response()->json(['response' => $response]);

        //if user intents are in English (WILL BE TRAINED BY TOMORROW)
      } elseif ($intent === 'about') {
        $otherResponses = [
            "This system is designed to handle document requests in Barangay Central Bicutan.",
             "This system is created to handle document requests through a chatbot in Barangay Central Bicutan.",
        ];

        $randomResponse = $otherResponses[array_rand($otherResponses)];
        $response = $randomResponse;
        return response()->json(['response' => $response]);

    } elseif ($intent === 'about_origin') {
        $otherResponses = [
            "This system is created by a group of 4th year BSCS students as a thesis in Taguig City University, and designed to handle online document requests in barangay Central Bicutan",
            "This system was designed and created by a group of college students studying under Bachelor of Science in Computer Science in Taguig City University.",
        ];

        $randomResponse = $otherResponses[array_rand($otherResponses)];
        $response = $randomResponse;
        return response()->json(['response' => $response]);

    } elseif ($intent === 'about_dev') {
        $otherResponses = [
            "This system was created in just one semester by a group of students studying Computer Science in Taguig City University using Flutter SDK and Laravel framework",
            "The system was created using Flutter SDK and Laravel framework as a thesis by a certain group of students studying Computer Science in Taguig City University",
        ];

        $randomResponse = $otherResponses[array_rand($otherResponses)];
        $response = $randomResponse;
        return response()->json(['response' => $response]);

    } elseif ($intent === 'about_scope') {
        $otherResponses = [
            "The scope of this system requires an Internet connection and the system generates a QR code containing your information along with the document you're requesting",
            "It requires a internet connection and a browser to access our system, the system makes it easier to request documents in the barangay by generating a QR code that contains your information along with the document your requesting.",
        ];
        $randomResponse = $otherResponses[array_rand($otherResponses)];
        $response = $randomResponse;
        return response()->json(['response' => $response]);
    } elseif ($intent === 'about_benefit') {
        $otherResponses = [
          //  "Ang benefisyong makukuha dito sa aming sistema, na mas mapapadali at less hassle dahil di na sila pupunta sa barangay para mag request ng dokumento online",
            "The benefits you will get by using our system, it will be easier and less hassle as you will only go to our barangay to claim you desired document you've requested online.",
        ];

        $randomResponse = $otherResponses[array_rand($otherResponses)];
        $response = $randomResponse;
        return response()->json(['response' => $response]);

    } elseif ($intent === 'stay_intent') {
        $otherResponses = [
          //  "Ang benefisyong makukuha dito sa aming sistema, na mas mapapadali at less hassle dahil di na sila pupunta sa barangay para mag request ng dokumento online",
            "Around a minimum of 6 / Six months before you can obtain documents in the Barangay Hall, and generally, you can obtain basic documents like a barangay clearance or ID shortly after establishing residency in the barangay.",
        ];

        $randomResponse = $otherResponses[array_rand($otherResponses)];
        $response = $randomResponse;
        return response()->json(['response' => $response]);
    } else {
        // Handle unrecognized intent here
        $otherResponses = [
            "I'm sorry, I couldn't understand your request.",
            "Patawad, Hindi ko po maintindihan ang iyong request",
            "My apologies, I can't understand your request",
        ];
        $randomResponse = $otherResponses[array_rand($otherResponses)];
        $response = $randomResponse;
        return response()->json(['response' => $response]);
    }
   // return response()->json(['response' => $response ?? '']);
}
}

//cut content from old version of system 

//public function searchCensus(Request $request)
//{
//    $this->validate($request, [
//        'firstname' => 'required|string',
//        'middlename' => 'required|string',
//        'lastname' => 'required|string',
//    ]);

 //   $firstName = $request->input('firstname');
 //   $middleName = $request->input('middlename');
 //   $lastName = $request->input('lastname');

 //   Log::info('Full Name: ' . $firstName . ', ' . $middleName . ',' . $lastName);

 //   $query = census::where('firstname', $firstName)
  //                  ->where('lastname', $lastName);

 //   if (!empty($middleName)) {
 //       $query->where('middlename', $middleName);
 //   }

 //   $user = $query->first();

 //   if ($user) {
 //       $response = "We found your name in our records! Please wait; a form will pop up on your screen, and you can fill out more of your details there.";
 //       return response()->json(['response' => $response, 'action' => 'show_information_form']);
 //   } else {

 //       $otherResponses = [
  //          "Sorry, we could not find your name in our records... Please try again.",
  //          "My apologies, the system could not find your name in our records... Maybe your name is not in our census yet.",
  //      ];
  //      $randomResponse = $otherResponses[array_rand($otherResponses)];
  //      return response()->json(['response' => $randomResponse]);
  //  }
//}

    
//}    