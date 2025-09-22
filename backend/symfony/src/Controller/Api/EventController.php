<?php

namespace App\Controller\Api;

use App\Entity\Event;
use App\Repository\EventRepository;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Routing\Annotation\Route;


#[Route('/api/events')]
class EventController extends AbstractController

{
    #[Route('', name: 'api_events_list', methods: ['GET'])]
    public function list(EventRepository $eventRepository): JsonResponse
    {
        $events = $eventRepository->findAll();

    $data = [];
    foreach ($events as $event) {
        $data[] = [
            'id' => $event->getId(),
            'title' => $event->getTitle(),
            'description' => $event->getDescription(),
            'date' => $event->getDate() ? $event->getDate()->format('Y-m-d H:i:s') : null,
            'createdBy' => $event->getCreatedBy() ? $event->getCreatedBy()->getId() : null,
        ];
    }

        return $this->json($data);
    }

#[Route('/{id}', name: 'api_events_show', methods: ['GET'])]
public function show(int $id, EventRepository $eventRepository): JsonResponse
{
    $event = $eventRepository->find($id);

    if (!$event) {
        return $this->json(['error' => 'Event not found'], 404);
    }


    $data = [
        'id' => $event->getId(),
        'title' => $event->getTitle(),
        'description' => $event->getDescription(),
        'date' => $event->getDate()?->format('Y-m-d H:i:s'),
        'createdBy' => $event->getCreatedBy()?->getId(),
    ];

    return $this->json($data);
}


#[Route('', name: 'api_events_create', methods: ['POST'])]
public function create(Request $request, EntityManagerInterface $em): JsonResponse
{
    $data = json_decode($request->getContent(), true);

    if (!$data || !isset($data['title'], $data['description'], $data['date'])) {
        return $this->json(['error' => 'Invalid data'], 400);
    }

    $event = new Event();
    $event->setTitle($data['title']);
    $event->setDescription($data['description']);
    $event->setDate(new \DateTime($data['date']));

    $em->persist($event);
    $em->flush();

    return $this->json([
        'id' => $event->getId(),
        'title' => $event->getTitle(),
        'description' => $event->getDescription(),
        'date' => $event->getDate()?->format('Y-m-d H:i:s'),
        'createdBy' => $event->getCreatedBy()?->getId(),
    ], 201);
}



#[Route('/{id}', name: 'api_events_update', methods: ['PUT'])]
public function update(int $id, Request $request, EventRepository $eventRepository, EntityManagerInterface $em): JsonResponse
{
    $event = $eventRepository->find($id);

    if (!$event) {
        return $this->json(['error' => 'Event not found'], 404);
    }

    $data = json_decode($request->getContent(), true);

    if (isset($data['title'])) {
        $event->setTitle($data['title']);
    }
    if (isset($data['description'])) {
        $event->setDescription($data['description']);
    }
    if (isset($data['date'])) {
        $event->setDate(new \DateTime($data['date']));
    }

    $em->flush();

    return $this->json([
        'id' => $event->getId(),
        'title' => $event->getTitle(),
        'description' => $event->getDescription(),
        'date' => $event->getDate()->format('Y-m-d H:i:s'),
        'createdBy' => $event->getCreatedBy()?->getId(),
    ]);
}

#[Route('/{id}', name: 'api_events_delete', methods: ['DELETE'])]
public function delete(int $id, EventRepository $eventRepository, EntityManagerInterface $em): JsonResponse
{
    $event = $eventRepository->find($id);

    if (!$event) {
        return $this->json(['error' => 'Event not found'], 404);
    }

    $em->remove($event);
    $em->flush();

    return $this->json(['message' => 'Event deleted successfully']);
}



}
