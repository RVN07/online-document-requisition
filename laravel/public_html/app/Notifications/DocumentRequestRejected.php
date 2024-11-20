<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class DocumentRequestRejected extends Notification
{
    use Queueable;

    protected $documentRequest;

    public function __construct($documentRequest)
    {
        $this->documentRequest = $documentRequest;
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
        ->subject('Document Request Rejected')
        ->line("We are sorry, {$this->documentRequest->firstName} {$this->documentRequest->lastName},")
        ->line("Your document request of {$this->documentRequest->documenttype} has been rejected. We are truly sorry.")
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
