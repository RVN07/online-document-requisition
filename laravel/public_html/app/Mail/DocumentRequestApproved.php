<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;
use App\Models\DocumentRequest;


class DocumentRequestApproved extends Mailable
{
    use Queueable, SerializesModels;

    
    public $documentRequest;

    /**
     * Create a new message instance.
     */

     public function build()
     {
        return $this->subject('Document Request Approved')
        ->view('emails.document_approval')
        ->with([
            'documenttype' => $this->documentRequest['documenttype'],
            'claim_date' => $this->documentRequest['claim_date']
// Replace with the actual claim date key
        ]);
     }


    public function __construct($documentRequest)
    {
        $this->documentRequest = $documentRequest;
    }

    /**
     * Get the message envelope.
     */
    public function envelope(): Envelope
    {
        return new Envelope(
            subject: 'Document Request Approved',
        );
    }

    /**
     * Get the message content definition.
     */
    public function content(): Content
{
    return new Content(
        view: 'emails.document_approval',
    );
}


    /**
     * Get the attachments for the message.
     *
     * @return array<int, \Illuminate\Mail\Mailables\Attachment>
     */
    public function attachments(): array
    {
        return [];
    }
}
