<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class DocumentRequestApproved extends Notification
{
        use Queueable;

    protected $documentRequest;
    protected $claimDateFromRequest;

    public function __construct($documentRequest, $claimDateFromRequest)
    {
        $this->documentRequest = $documentRequest;
        $this->claimDateFromRequest = $claimDateFromRequest;
    }

    /**
     * Get the notification's delivery channels.
     *
     * @return array<int, string>
     */
    public function via(object $notifiable): array
    {
        return ['mail'];
    }

    /**
     * Get the mail representation of the notification.
     */
    public function toMail(object $notifiable): MailMessage
{
    return (new MailMessage)
        ->subject('Document Request Approved')
        ->line("Hello! {$this->documentRequest->firstName} {$this->documentRequest->lastName},")
        ->line("Your document request of {$this->documentRequest->documenttype} has been approved and is now currently processed. You will claim your document on {$this->claimDateFromRequest}.")
        ->action('View Document Request', url('/document-requests/' . $this->documentRequest->id))
        ->line('Thank you for using our service.');
}


    /**
     * Get the array representation of the notification.
     *
     * @return array<string, mixed>
     */
    public function toArray(object $notifiable): array
    {
        return [
            //
        ];
    }
}
