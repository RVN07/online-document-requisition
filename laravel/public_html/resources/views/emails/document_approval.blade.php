<!-- resources/views/emails/document_approval.blade.php -->

<p>Hello, {{ $documentRequest->firstname }} {{ $documentRequest->lastname }},</p>

<p>Your document request of {{ $documentRequest->documenttype }} has been approved and is now being processed. You can claim your document on {{ $claimDate }}.</p>

<p>Below is an image of what the approved document looks like:</p>

@if($documentRequest->documenttype === 'Barangay ID')
    <img src="{{ asset('storage/images/barangay_id_sample.jpg') }}" alt="Barangay ID Sample">
@elseif($documentRequest->documenttype === 'Barangay Clearance')
    <img src="{{ asset('storage/images/brgy_clearance_sample.PNG') }}" alt="Barangay Clearance Sample">
@elseif($documentRequest->documenttype === 'Barangay Certificate')
    <img src="{{ asset('storage/images/brgy_certificate_sample.PNG') }}" alt="Barangay Certificate Sample">
@elseif($documentRequest->documenttype === 'Certificate of Indigency')
    <img src="{{ asset('storage/images/cert_of_indigency_sample.PNG') }}" alt="Certificate of Indigency sample">
{{-- Add more conditions as needed --}}
@else
    <p>No image available for this document type.</p>
@endif

<p>Thank you!</p>
