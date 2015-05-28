﻿using UnityEngine;
using System.Collections;

public class NewThrowableRock : MonoBehaviour {

	public bool isSelected = false;
	public bool isGrowing = false;
	public bool inTheAir = false;
	[HideInInspector]
	public int selectionNumber = 0;
	
	public Vector3 normalScale;
	
	[HideInInspector]
	public bool homingAttackBool = false;
	[HideInInspector]
	public Transform aimHoming;
	[HideInInspector]
	public bool beingThrowned = false;
	[HideInInspector]
	public int throwedRockNumber = 0;
	[HideInInspector]
	public bool isThrowed = false;
	
	public float throwForce = 1000;
	
	public bool canExplode = false;
	public Vector3 posAtLaunch = Vector3.zero;
	public float maxTravelDistance = 15;
	public float DecelerationRate = 15;
	public float maxVelocityWhenDecelerating = 22;
	public float growingRate = .5f;
	
	public AudioSource impact;
	
	private GameObject player;
	
	[HideInInspector]
	public bool growingMyself = true;
	
	// Use this for initialization
	void Start () 
	{
		player = GameObject.Find ("Player");
	}
	
	// Update is called once per frame
	void Update () 
	{
		#region track distance travelled
		if (Vector3.SqrMagnitude(transform.position - posAtLaunch) > maxTravelDistance * maxTravelDistance && !isSelected && isThrowed)
		{
			rigidbody.useGravity = true;
			constantForce.force = Vector3.zero;
			
			if (Vector3.SqrMagnitude(rigidbody.velocity) > maxVelocityWhenDecelerating * maxVelocityWhenDecelerating)
			{
				rigidbody.drag = DecelerationRate;
			}
			else
				rigidbody.drag = 0;
			
			homingAttackBool = false;
		}
		#endregion
		
		if (homingAttackBool)
			homingAttack();
	}
	
	//With this method, we make sure that if the player throwed the rock toward an enemy, he can be almost sure he will hit it.
	void homingAttack ()
	{
		if (aimHoming.GetComponent <BasicEnemy> ().canGetHit) 
		{	
			Vector3 throwDir = aimHoming.position - this.transform.position;
			throwDir.Normalize ();
			
			this.rigidbody.constraints = RigidbodyConstraints.None;
			
			constantForce.force = throwDir * throwForce;
		} 
		else
			homingAttackBool = false;
	}
	
	//To avoid the rock to be difficult to aim, we reactivate gravity only after the first hit, when it's not selected anymore.
	void OnCollisionEnter (Collision collider)
	{
		JustHitSomething();
		
		Debug.Log ("Velocity = " + Vector3.SqrMagnitude (rigidbody.velocity));
		
		if (Vector3.SqrMagnitude (rigidbody.velocity) > 3000)
		{
			impact.volume = 1;
			impact.pitch = 1;
		}
		else if (Vector3.SqrMagnitude (rigidbody.velocity) < 3000 && Vector3.SqrMagnitude (rigidbody.velocity) > 2000)
		{
			impact.volume = .75f;
			impact.pitch = .9f;
		}
		else if (Vector3.SqrMagnitude (rigidbody.velocity) < 2000 && Vector3.SqrMagnitude (rigidbody.velocity) > 1000)
		{
			impact.volume = .5f;
			impact.pitch = .8f;
		}
		else if (Vector3.SqrMagnitude (rigidbody.velocity) < 1000)
		{
			impact.volume = .25f;
			impact.pitch = .7f;
		}
		
		
		
		impact.Play ();
	}
	
	void JustHitSomething ()
	{
		if (!isSelected) 
		{
			rigidbody.useGravity = true;
			constantForce.force = Vector3.zero;
			homingAttackBool = false;
			beingThrowned = false;
		}
	}
	
	void InstantGrow ()
	{
		growingMyself = false;
	}
	
}
